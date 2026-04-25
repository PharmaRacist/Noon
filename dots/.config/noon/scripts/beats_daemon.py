#!/usr/bin/env python3

import argparse
import json
import os
import socket
import subprocess
import time

CONF_PATH = os.path.expanduser("~/.config/HyprNoon/beats.json")
PREVIEW_PID_FILE = "/tmp/beats_preview.pid"

DEFAULTS = {
    "socketPath": "/tmp/mpv.sock",
    "mpvLog": "/tmp/beats_daemon_mpv.log",
    "volumeNormalization": {
        "enabled": True,
        "replaygain": "track",
    },
    "eq": {
        "enabled": True,
        "eqBands": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    },
}


def load_conf() -> dict:
    if not os.path.exists(CONF_PATH):
        os.makedirs(os.path.dirname(CONF_PATH), exist_ok=True)
        with open(CONF_PATH, "w") as f:
            json.dump(DEFAULTS, f, indent=4)
        return dict(DEFAULTS)
    with open(CONF_PATH, "r") as f:
        data = json.load(f)
    merged = dict(DEFAULTS)
    merged.update(data)
    return merged


conf = load_conf()


def send_command(command: list):
    payload = json.dumps({"command": command}) + "\n"
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.connect(conf["socketPath"])
            s.sendall(payload.encode())
            s.settimeout(2)
            try:
                response = s.recv(4096)
                return json.loads(response.decode().strip())
            except (socket.timeout, json.JSONDecodeError):
                return None
    except (ConnectionRefusedError, FileNotFoundError, OSError):
        return None


def get_property(prop: str):
    result = send_command(["get_property", prop])
    if result and result.get("error") == "success":
        return result.get("data")
    return None


def is_mpv_running() -> bool:
    if not os.path.exists(conf["socketPath"]):
        return False
    result = send_command(["get_property", "pid"])
    return result is not None and result.get("error") == "success"


def build_eq_filter(bands: list) -> str:
    freqs = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    parts = [
        f"equalizer=f={freq}:width_type=o:width=2:g={float(gain)}"
        for freq, gain in zip(freqs, bands)
    ]
    return ",".join(parts)


def apply_eq():
    eq_conf = conf.get("eq", {})
    bands = eq_conf.get("eqBands", DEFAULTS["eq"]["eqBands"])
    if not eq_conf.get("enabled", False) or all(b == 0 for b in bands):
        send_command(["af", "set", ""])
        return
    if len(bands) != 10:
        return
    send_command(["af", "set", f"lavfi=[{build_eq_filter(bands)}]"])


def launch_mpv(playlist_path: str) -> bool:
    cmd = [
        "mpv",
        "--no-video",
        "--no-terminal",
        "--idle=yes",
        "--loop-playlist=inf",
        "--gapless-audio=yes",
        f"--input-ipc-server={conf['socketPath']}",
        f"--playlist={playlist_path}",
    ]

    if conf["volumeNormalization"]["enabled"]:
        cmd.append(f"--replaygain={conf['volumeNormalization']['replaygain']}")

    with open(conf["mpvLog"], "a") as log:
        subprocess.Popen(cmd, stdout=log, stderr=log, start_new_session=True)

    for _ in range(30):
        time.sleep(0.2)
        if not is_mpv_running():
            continue
        count = get_property("playlist-count")
        if count is not None and int(count) > 0:
            apply_eq()
            return True
    return False


def ensure_running(playlist_path: str) -> bool:
    if is_mpv_running():
        return True
    if os.path.exists(conf["socketPath"]):
        os.remove(conf["socketPath"])
    return launch_mpv(playlist_path)


def cmd_play_index(index: int, playlist_path: str):
    ensure_running(playlist_path)
    send_command(["playlist-play-index", index])


def cmd_play_file(filepath: str, playlist_path: str):
    ensure_running(playlist_path)
    send_command(["loadfile", filepath, "replace"])


def cmd_play_pause(playlist_path: str):
    ensure_running(playlist_path)
    send_command(["cycle", "pause"])


def cmd_next(playlist_path: str):
    ensure_running(playlist_path)
    send_command(["playlist-next"])


def cmd_prev(playlist_path: str):
    ensure_running(playlist_path)
    send_command(["playlist-prev"])


def cmd_stop():
    send_command(["quit"])
    if os.path.exists(conf["socketPath"]):
        os.remove(conf["socketPath"])


def cmd_seek(seconds: float, playlist_path: str):
    ensure_running(playlist_path)
    send_command(["seek", seconds, "relative"])


def cmd_preview_url(url: str):
    if os.path.exists(PREVIEW_PID_FILE):
        cmd_kill_preview()
    send_command(["set_property", "pause", True])
    proc = subprocess.Popen(
        ["mpv", "--no-video", "--no-terminal", "--ytdl-format=bestaudio", url],
        start_new_session=True,
    )
    with open(PREVIEW_PID_FILE, "w") as f:
        json.dump({"pid": proc.pid, "url": url}, f)


def cmd_preview_status():
    if not os.path.exists(PREVIEW_PID_FILE):
        print(json.dumps({"active": False}))
        return
    with open(PREVIEW_PID_FILE, "r") as f:
        data = json.load(f)
    pid = data.get("pid")
    url = data.get("url", "")
    try:
        os.kill(int(pid), 0)
        print(json.dumps({"active": True, "pid": pid, "url": url}))
    except (ProcessLookupError, ValueError):
        os.remove(PREVIEW_PID_FILE)
        print(json.dumps({"active": False}))


def cmd_kill_preview():
    if not os.path.exists(PREVIEW_PID_FILE):
        return
    with open(PREVIEW_PID_FILE, "r") as f:
        data = json.load(f)
    pid = data.get("pid")
    try:
        subprocess.run(["kill", str(pid)])
    except Exception:
        pass
    os.remove(PREVIEW_PID_FILE)


def cmd_refresh_config():
    global conf
    conf = load_conf()
    if not is_mpv_running():
        return
    apply_eq()


def cmd_status():
    if not is_mpv_running():
        print(json.dumps({"running": False}))
        return
    title = send_command(["get_property", "media-title"])
    index = send_command(["get_property", "playlist-pos"])
    paused = send_command(["get_property", "pause"])
    position = send_command(["get_property", "time-pos"])
    duration = send_command(["get_property", "duration"])
    volume = send_command(["get_property", "volume"])
    print(
        json.dumps(
            {
                "running": True,
                "title": title.get("data") if title else None,
                "index": index.get("data") if index else None,
                "paused": paused.get("data") if paused else None,
                "position": position.get("data") if position else None,
                "duration": duration.get("data") if duration else None,
                "volume": volume.get("data") if volume else None,
            }
        )
    )


def main():
    parser = argparse.ArgumentParser(description="beats_daemon - MPV controller")
    parser.add_argument(
        "command",
        choices=[
            "play-index",
            "play-file",
            "play-pause",
            "next",
            "prev",
            "stop",
            "seek",
            "status",
            "refresh-config",
            "preview-url",
            "kill-preview",
            "preview-status",
        ],
    )
    parser.add_argument("--index", type=int, default=0)
    parser.add_argument("--seconds", type=float, default=5.0)
    parser.add_argument("--playlist", type=str, default="")
    parser.add_argument("--url", type=str, default="")
    parser.add_argument("--file", type=str, default="")
    args = parser.parse_args()

    playlist = args.playlist

    if args.command == "play-index":
        cmd_play_index(args.index, playlist)
    elif args.command == "play-file":
        cmd_play_file(args.file, playlist)
    elif args.command == "play-pause":
        cmd_play_pause(playlist)
    elif args.command == "next":
        cmd_next(playlist)
    elif args.command == "prev":
        cmd_prev(playlist)
    elif args.command == "stop":
        cmd_stop()
    elif args.command == "seek":
        cmd_seek(args.seconds, playlist)
    elif args.command == "refresh-config":
        cmd_refresh_config()
    elif args.command == "preview-url":
        cmd_preview_url(args.url)
    elif args.command == "kill-preview":
        cmd_kill_preview()
    elif args.command == "preview-status":
        cmd_preview_status()
    elif args.command == "status":
        cmd_status()


if __name__ == "__main__":
    main()
