import argparse
import subprocess
import sys
from pathlib import Path

from oauth_service import NoonAuthenticator, revoke


def send_notification(message: str, notify: bool):
    if not notify:
        return
    icon = Path("~/.config/noon/assets/icons/noon-dark.png").expanduser()
    subprocess.run(["notify-send", "Noon", message, "-i", icon], check=False)


def cmd_auth(args):
    auth = NoonAuthenticator(args.id, args.secret, args.scopes)
    auth.auth_loopback(interactive=True)
    handler = auth.accountinfo.get("handler", "unknown")
    print(f"Authenticated as {handler}")
    send_notification(f"Authenticated as {handler}", args.notify)


def cmd_revoke(args):
    revoke(args.id)
    print("Revoked.")
    send_notification(f"Revoked credentials for {args.id}", args.notify)


def main():
    parser = argparse.ArgumentParser(prog="oauth_manager")
    sub = parser.add_subparsers(dest="command", required=True)

    auth_cmd = sub.add_parser("auth")
    auth_cmd.add_argument("--id", required=True)
    auth_cmd.add_argument("--secret", required=True)
    auth_cmd.add_argument("--scopes", required=True)
    auth_cmd.add_argument("--notify", action="store_true")

    revoke_cmd = sub.add_parser("revoke")
    revoke_cmd.add_argument("--id", required=True)
    revoke_cmd.add_argument("--notify", action="store_true")

    args = parser.parse_args()
    try:
        {"auth": cmd_auth, "revoke": cmd_revoke}[args.command](args)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
