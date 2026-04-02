#!/usr/bin/env python3

import argparse
import glob
import json
import os
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class LaunchConfig:
    exe: str
    wine: str = "wine"
    gamescope: bool = False
    gamescope_args: list = field(default_factory=list)
    gamemode: bool = False
    dxvk: bool = False
    vkd3d: bool = False
    mangohud: bool = False
    env: dict = field(default_factory=dict)
    extra_args: list = field(default_factory=list)


def find_wine_versions() -> list[str]:
    candidates = []

    system_wine = shutil.which("wine")
    if system_wine:
        candidates.append(system_wine)

    for pattern in [
        "/opt/wine*/bin/wine",
        "/opt/proton*/files/bin/wine",
        "/usr/local/wine*/bin/wine",
        str(Path.home() / ".local/share/lutris/runners/wine/*/bin/wine"),
        str(Path.home() / ".steam/steam/steamapps/common/Proton*/files/bin/wine"),
        "/usr/share/steam/steamapps/common/Proton*/files/bin/wine",
    ]:
        candidates.extend(glob.glob(pattern))

    seen = set()
    result = []
    for w in candidates:
        resolved = str(Path(w).resolve())
        if resolved not in seen and Path(w).is_file():
            seen.add(resolved)
            result.append(w)

    return result


def build_command(cfg: LaunchConfig) -> tuple[list[str], dict]:
    cmd = []
    env = os.environ.copy()
    env.update(cfg.env)

    if cfg.gamescope:
        cmd += ["gamescope"] + cfg.gamescope_args + ["--"]

    if cfg.gamemode:
        gamemoderun = shutil.which("gamemoderun")
        if gamemoderun:
            cmd.append(gamemoderun)

    if cfg.mangohud:
        mangohud = shutil.which("mangohud")
        if mangohud:
            cmd.append(mangohud)

    if cfg.dxvk:
        env["DXVK_ASYNC"] = "1"
        env["WINEDLLOVERRIDES"] = "d3d9,d3d10core,d3d11,dxgi=n,b"

    if cfg.vkd3d:
        env["VKD3D_FEATURE_FLAGS"] = "VKD3D_FEATURE_FLAG_DXR"
        existing = env.get("WINEDLLOVERRIDES", "")
        env["WINEDLLOVERRIDES"] = (existing + ";d3d12=n,b").lstrip(";")

    cmd += [cfg.wine] + cfg.extra_args + [cfg.exe]

    return cmd, env


def launch(cfg: LaunchConfig) -> subprocess.Popen:
    cmd, env = build_command(cfg)
    return subprocess.Popen(cmd, env=env)


def config_to_json(cfg: LaunchConfig) -> str:
    cmd, _ = build_command(cfg)
    payload = {
        "command": cmd,
        "env_overrides": cfg.env,
        "flags": {
            "gamescope": cfg.gamescope,
            "gamescope_args": cfg.gamescope_args,
            "gamemode": cfg.gamemode,
            "dxvk": cfg.dxvk,
            "vkd3d": cfg.vkd3d,
            "mangohud": cfg.mangohud,
        },
    }
    return json.dumps(payload, indent=2)


def cmd_list_runners(_args):
    wines = find_wine_versions()
    runners = []
    for i, w in enumerate(wines):
        parts = list(Path(w).parts)
        name = parts[-4] if len(parts) >= 4 else Path(w).stem
        runners.append({"index": i, "name": name, "path": w})
    print(json.dumps(runners, indent=2))


def cmd_run(args):
    wines = find_wine_versions()

    if args.runner is not None:
        if args.runner.isdigit():
            idx = int(args.runner)
            if idx >= len(wines):
                print(
                    f"Runner index {idx} out of range. Run list-runners to see options."
                )
                raise SystemExit(1)
            wine = wines[idx]
        else:
            wine = args.runner
    elif wines:
        wine = wines[0]
    else:
        print("No Wine runners found. Specify one with --runner.")
        raise SystemExit(1)

    gamescope_args = args.gamescope_args.split() if args.gamescope_args else []
    extra_env = {}
    for pair in args.env or []:
        k, _, v = pair.partition("=")
        extra_env[k] = v

    cfg = LaunchConfig(
        exe=args.exe,
        wine=wine,
        gamescope=args.gamescope,
        gamescope_args=gamescope_args,
        gamemode=args.gamemode,
        dxvk=args.dxvk,
        vkd3d=args.vkd3d,
        mangohud=args.mangohud,
        env=extra_env,
        extra_args=args.wine_args or [],
    )

    print(config_to_json(cfg))

    if not args.dry_run:
        proc = launch(cfg)
        print(f"Launched PID {proc.pid}")
        proc.wait()
        print(f"Exited with code {proc.returncode}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="games_backend",
        description="Launch Windows games on Linux via Wine + gamescope/gamemode/DXVK/VKD3D/MangoHud.",
    )
    sub = parser.add_subparsers(dest="command", metavar="COMMAND")
    sub.required = True

    sub.add_parser("list-runners", help="List all detected Wine/Proton runners.")

    run = sub.add_parser("run", help="Launch a game.")
    run.add_argument(
        "exe", help="Path to the Windows executable (e.g. 'C:/game/game.exe')."
    )
    run.add_argument(
        "--runner",
        metavar="INDEX|PATH",
        help="Wine runner: index from list-runners or absolute path. Defaults to first found.",
    )
    run.add_argument("--gamescope", action="store_true", help="Wrap with gamescope.")
    run.add_argument(
        "--gamescope-args",
        metavar="ARGS",
        help="Extra gamescope arguments as a quoted string (e.g. '-W 1920 -H 1080 -f').",
    )
    run.add_argument("--gamemode", action="store_true", help="Run via gamemoderun.")
    run.add_argument("--dxvk", action="store_true", help="Enable DXVK (d3d9/10/11).")
    run.add_argument(
        "--vkd3d", action="store_true", help="Enable VKD3D-Proton (d3d12)."
    )
    run.add_argument("--mangohud", action="store_true", help="Overlay MangoHud.")
    run.add_argument(
        "--env", metavar="KEY=VALUE", nargs="*", help="Extra environment variables."
    )
    run.add_argument(
        "--wine-args",
        metavar="ARG",
        nargs="*",
        help="Extra arguments passed to Wine before the exe.",
    )
    run.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the JSON config without launching.",
    )

    return parser


if __name__ == "__main__":
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "list-runners":
        cmd_list_runners(args)
    elif args.command == "run":
        cmd_run(args)
