#!/usr/bin/env python3
"""
HyprNoon Alarm System - Complete with "9:30" + friendly time parsing
"""

import asyncio
import fcntl
import json
import os
import signal
import subprocess
import sys
import uuid
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional

DB_PATH = Path.home() / ".config/HyprNoon/alarms.json"


class AlarmStore:
    def __init__(self, db_path: Path):
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)

    def load(self) -> List[Dict]:
        if not self.db_path.exists():
            return []
        try:
            with open(self.db_path, "r") as f:
                fcntl.flock(f.fileno(), fcntl.LOCK_SH)
                content = f.read()
                fcntl.flock(f.fileno(), fcntl.LOCK_UN)
                if not content.strip():
                    return []
                alarms = json.loads(content)
            return self._filter_valid_alarms(alarms)
        except Exception as e:
            print(f"Error loading alarms: {e}")
            return []

    # def save(self, alarms: List[Dict]) -> None:
    #     valid_alarms = self._filter_valid_alarms(alarms)
    #     try:
    #         tmp_path = self.db_path.with_suffix(".tmp")
    #         with open(tmp_path, "w") as f:
    #             fcntl.flock(f.fileno(), fcntl.LOCK_EX)
    #             json.dump(valid_alarms, f, indent=2)
    #             f.flush()
    #             os.fsync(f.fileno())
    #             fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    #         tmp_path.replace(self.db_path)
    #     except Exception as e:
    #         print(f"Error saving alarms: {e}")
    def save(self, alarms: List[Dict]) -> None:
        valid_alarms = self._filter_valid_alarms(alarms)
        try:
            # open real file directly, truncate in place
            with open(self.db_path, "w") as f:
                fcntl.flock(f.fileno(), fcntl.LOCK_EX)
                json.dump(valid_alarms, f, indent=2)
                f.flush()
                os.fsync(f.fileno())
                fcntl.flock(f.fileno(), fcntl.LOCK_UN)
        except Exception as e:
            print(f"Error saving alarms: {e}")

    @staticmethod
    def _filter_valid_alarms(alarms: List[Dict]) -> List[Dict]:
        now = datetime.now()
        valid = []
        for alarm in alarms:
            if not isinstance(alarm, dict) or "id" not in alarm:
                continue
            try:
                alarm_time = datetime.fromisoformat(alarm["time"])
                ringed = alarm.get("ringed", False)
                ringed_at = alarm.get("ringed_at")

                keep = False
                if alarm_time > now:
                    keep = True
                elif not ringed:
                    keep = True
                elif ringed_at:
                    ringed_time = datetime.fromisoformat(ringed_at)
                    if (now - ringed_time).total_seconds() / 3600 < 1:
                        keep = True

                if keep:
                    alarm.setdefault("ui_id", alarm["id"])
                    alarm.setdefault("period", AlarmManager.format_time(alarm["time"]))
                    valid.append(alarm)
            except (ValueError, KeyError):
                continue
        return valid


class AlarmManager:
    def __init__(self, store: AlarmStore):
        self.store = store
        self.alarms = store.load()
        self.running = False

    @staticmethod
    def parse_friendly_time(time_str: str) -> Optional[datetime]:
        """Parse ALL: '9:30', '10min', '2h30m', '3pm', 'tomorrow 9am'"""
        now = datetime.now()
        time_str = time_str.strip()

        # ISO format first
        try:
            return datetime.fromisoformat(time_str.replace(" ", "T"))
        except ValueError:
            pass

        # Time of day patterns: "9:30", "9:30pm", "14:30"
        time_patterns = [
            "%H:%M",  # 14:30, 9:30
            "%I:%M%p",  # 9:30pm
            "%I:%M %p",  # 9:30 pm
            "%H",  # 15
            "%I%p",  # 3pm
            "%I %p",  # 3 pm
            "%I",  # 9 (AM)
        ]

        for pattern in time_patterns:
            try:
                dt = datetime.strptime(time_str.lower(), pattern)
                target = now.replace(
                    year=now.year,
                    month=now.month,
                    day=now.day,
                    hour=dt.hour,
                    minute=dt.minute,
                    second=0,
                    microsecond=0,
                )
                if target <= now:
                    target += timedelta(days=1)
                return target
            except ValueError:
                continue

        # Relative times + tomorrow
        time_delta = timedelta()
        original = time_str.lower()
        clean_str = "".join(c for c in original if c.isdigit() or c in "hms ")

        if "tomorrow" in original:
            time_delta += timedelta(days=1)

        i = 0
        while i < len(clean_str):
            if clean_str[i].isdigit():
                num = 0
                while i < len(clean_str) and clean_str[i].isdigit():
                    num = num * 10 + int(clean_str[i])
                    i += 1
                if i < len(clean_str):
                    unit = clean_str[i].lower()
                    if unit == "h":
                        time_delta += timedelta(hours=num)
                    elif unit == "m":
                        time_delta += timedelta(minutes=num)
                    elif unit == "s":
                        time_delta += timedelta(seconds=num)
                    i += 1
                else:
                    time_delta += timedelta(minutes=num)
            else:
                i += 1

        if time_delta.total_seconds() > 0:
            return now + time_delta

        return None

    @staticmethod
    def format_time(iso_time: str) -> str:
        date = datetime.fromisoformat(iso_time)
        h = date.hour % 12 or 12
        m = f"{date.minute:02d}"
        return f"{h}:{m} {'PM' if date.hour >= 12 else 'AM'}"

    def add(
        self, time_str: str, message: str, remind_interval: Optional[int] = None
    ) -> str:
        parsed_time = self.parse_friendly_time(time_str)
        if not parsed_time:
            print(f"✗ Invalid time: {time_str}")
            print("Examples: 9:30, 14:30, 10min, 2h30m, 3pm, tomorrow 9am")
            return ""

        self.alarms = self.store.load()
        timer_id = str(uuid.uuid4())[:8]
        alarm = {
            "id": timer_id,
            "ui_id": timer_id,
            "time": parsed_time.isoformat(),
            "message": message or f"Alarm {timer_id}",
            "period": self.format_time(parsed_time.isoformat()),
            "ringed": False,
            "ringed_at": None,
            "remind_interval": remind_interval,
            "last_reminded": None,
            "active": True,
        }
        self.alarms.append(alarm)
        self.store.save(self.alarms)
        print(f"✓ Added {timer_id}: {alarm['period']} - {message}")
        return timer_id

    def toggle(self, timer_id: str, set_active: bool) -> bool:
        self.alarms = self.store.load()
        for alarm in self.alarms:
            if alarm["id"] == timer_id:
                alarm["ringed"] = not set_active
                alarm["active"] = set_active
                if set_active:
                    alarm["ringed_at"] = None
                    alarm["last_reminded"] = None
                alarm["period"] = self.format_time(alarm["time"])
                self.store.save(self.alarms)
                status = "activated" if set_active else "deactivated"
                print(f"✓ Timer {timer_id} {status}: {alarm['message']}")
                return True
        print(f"✗ Timer {timer_id} not found")
        return False

    def list_json(self) -> str:
        self.alarms = self.store.load()
        return json.dumps(self.alarms, default=str)

    def clear(self) -> bool:
        self.alarms = []
        self.store.save(self.alarms)
        print("✓ All alarms cleared")
        return True

    def get_time_until_next(self) -> int:
        self.alarms = self.store.load()
        now = datetime.now()
        active = [
            a
            for a in self.alarms
            if a.get("active", True)
            and not a.get("ringed", False)
            and datetime.fromisoformat(a["time"]) > now
        ]
        if not active:
            return -1
        next_alarm = min(active, key=lambda a: datetime.fromisoformat(a["time"]))
        return int((datetime.fromisoformat(next_alarm["time"]) - now).total_seconds())


async def run_daemon(manager):
    """Daemon loop with notifications"""
    print("🔔 Alarm daemon started - checking every 5s")
    while True:
        try:
            manager.alarms = manager.store.load()
            now = datetime.now()

            for alarm in manager.alarms[:]:
                if not alarm.get("ringed", False) and alarm.get("active", True):
                    alarm_time = datetime.fromisoformat(alarm["time"])
                    if alarm_time <= now:
                        print(f"⏰ TRIGGERING: {alarm['message']}")
                        # Send notification (HyprNoon IPC)
                        try:
                            subprocess.run(
                                [
                                    "qs",
                                    "-c",
                                    str(Path.home() / ".config/noon"),
                                    "ipc",
                                    "call",
                                    "global",
                                    "wake",
                                    alarm["message"],
                                ],
                                check=True,
                                timeout=5,
                                capture_output=True,
                            )
                        except:
                            print("Notification failed")

                        alarm["ringed"] = True
                        alarm["ringed_at"] = now.isoformat()
                        manager.store.save(manager.alarms)

            await asyncio.sleep(1)
        except Exception as e:
            print(f"Daemon error: {e}")
            await asyncio.sleep(1)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 alarm_service.py <add|toggle|list|clear|daemon>")
        print("Examples:")
        print("  python3 alarm_service.py add '9:30' 'Morning meeting'")
        print("  python3 alarm_service.py add '10min' 'Break time'")
        return

    store = AlarmStore(DB_PATH)
    manager = AlarmManager(store)

    cmd = sys.argv[1]

    if cmd == "add":
        if len(sys.argv) < 4:
            print("Usage: python3 alarm_service.py add <time> <message> [remind_min]")
            return
        time_str = sys.argv[2]
        message = sys.argv[3]
        remind = int(sys.argv[4]) if len(sys.argv) > 4 else None
        manager.add(time_str, message, remind)

    elif cmd == "toggle":
        if len(sys.argv) < 4:
            print("Usage: python3 alarm_service.py toggle <timer_id> <true|false>")
            return
        timer_id = sys.argv[2]
        set_active = sys.argv[3].lower() == "true"
        manager.toggle(timer_id, set_active)

    elif cmd == "list":
        print(manager.list_json())

    elif cmd == "clear":
        manager.clear()

    elif cmd == "daemon":
        try:
            asyncio.run(run_daemon(manager))
        except KeyboardInterrupt:
            print("\nDaemon stopped")


if __name__ == "__main__":
    main()
