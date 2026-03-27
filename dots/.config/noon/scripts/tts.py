#!/usr/bin/env python3

import argparse
import os
import signal
import socket
import subprocess
import sys
from pathlib import Path

SOCKET_PATH = Path("/tmp/tts.sock")
LOCK_FILE = Path("/tmp/tts_daemon.lock")


def log(status, msg):
    print(f"tts|{status}|{msg}", file=sys.stderr, flush=True)


def is_running():
    if not LOCK_FILE.exists():
        return False
    return Path(f"/proc/{LOCK_FILE.read_text().strip()}").exists()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path)
    parser.add_argument("--load", action="store_true")
    parser.add_argument("--unload", action="store_true")
    parser.add_argument("--status", action="store_true")
    parser.add_argument("text", nargs="*")
    args = parser.parse_args()

    if args.status:
        log("ok", "daemon_running" if is_running() else "daemon_stopped")

    elif args.load:
        if is_running():
            log("error", "daemon_already_running")
            sys.exit(1)
        if not args.config:
            log("error", "config_required")
            sys.exit(1)
        daemon = Path(__file__).parent / "tts_daemon.py"
        subprocess.Popen(
            [sys.executable, str(daemon), "--config", str(args.config)],
            stderr=sys.stderr,
        )
        log("ok", "daemon_started")

    elif args.unload:
        if not is_running():
            log("error", "daemon_not_running")
            sys.exit(1)
        os.kill(int(LOCK_FILE.read_text().strip()), signal.SIGTERM)
        log("ok", "daemon_stopped")

    elif args.text:
        if not is_running() or not SOCKET_PATH.exists():
            log("error", "daemon_not_running")
            sys.exit(1)
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.connect(str(SOCKET_PATH))
            s.sendall(" ".join(args.text).encode())
        log("ok", "sent")

    else:
        log("error", "no_action")
        sys.exit(1)


if __name__ == "__main__":
    main()
