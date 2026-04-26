import json
import os
import subprocess
import time
import urllib
import webbrowser

from requests_oauth2client import OAuth2Client

OAUTH_STATE_PATH = os.path.expanduser("~/.local/state/noon/user/generated/oauth.json")


class NoonAuthenticator:
    def __init__(self, service_name, scopes, client_id=None, client_secret=None):
        self.service = service_name
        self.scopes = scopes

        env_prefix = f"NOON_{service_name.upper()}"
        self.cid = client_id or os.environ.get(f"{env_prefix}_ID")
        self.sec = client_secret or os.environ.get(f"{env_prefix}_SECRET")

        if not self.cid:
            raise ValueError(
                f"Auth Error: Missing Client ID for service '{service_name}'. "
                f"Please set {env_prefix}_ID environment variable."
            )

        self.client = OAuth2Client(
            token_endpoint="https://oauth2.googleapis.com/token",
            client_id=self.cid,
            client_secret=self.sec,
        )

    def get_token(self) -> dict:
        if not os.path.exists(OAUTH_STATE_PATH):
            return None
        try:
            with open(OAUTH_STATE_PATH, "r") as f:
                data = json.load(f)
                # Ensure we return the inner dictionary (the one with access_token)
                return data.get(self.service)
        except:
            return None

    def is_authenticated(self) -> bool:
        token_data = self.get_token()
        return bool(token_data and "access_token" in token_data)

    def auth(self, interactive=False):
        """Executes the Device Authorization Grant flow."""
        # Note: endpoint can be customized if you ever use non-Google services
        resp = self.client.session.post(
            "https://oauth2.googleapis.com/device/code",
            data={"client_id": self.cid, "scope": self.scopes},
        )
        resp.raise_for_status()
        data = resp.json()

        user_code = data["user_code"]
        device_code = data["device_code"]
        url = data["verification_url"]
        interval = data.get("interval", 5)

        # Handle clipboard for Wayland
        try:
            subprocess.run(["wl-copy"], input=user_code.encode(), check=True)
        except FileNotFoundError:
            pass

        if interactive:
            print(f"[{self.service.upper()}] Open: {url}")
            print(
                f"[{self.service.upper()}] Enter Code: {user_code} (Copied to clipboard)"
            )
            webbrowser.open(url)
            input("Press Enter once you have authorized in the browser...")
        else:
            webbrowser.open(url)
            subprocess.run(
                [
                    "notify-send",
                    f"Noon Auth: {self.service}",
                    f"Code: {user_code}\nCopied to clipboard. Authorize in browser.",
                ]
            )

        # Polling for token
        while True:
            token_resp = self.client.session.post(
                self.client.token_endpoint,
                data={
                    "client_id": self.cid,
                    "client_secret": self.sec,
                    "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
                    "device_code": device_code,
                },
            )

            token_data = token_resp.json()
            if "error" in token_data:
                if token_data["error"] == "authorization_pending":
                    time.sleep(interval)
                    continue
                raise Exception(f"OAuth Error ({self.service}): {token_data['error']}")

            self._save_to_vault(token_data)
            return token_data

    def revoke(self):
        """Removes the service token from the central vault."""
        if not os.path.exists(OAUTH_STATE_PATH):
            return
        try:
            with open(OAUTH_STATE_PATH, "r") as f:
                state = json.load(f)
            if self.service in state:
                del state[self.service]
                with open(OAUTH_STATE_PATH, "w") as f:
                    json.dump(state, f, indent=2)
        except:
            pass

    def _save_to_vault(self, token_data):
        import time

        os.makedirs(os.path.dirname(OAUTH_STATE_PATH), exist_ok=True)
        state = {}
        if os.path.exists(OAUTH_STATE_PATH):
            try:
                with open(OAUTH_STATE_PATH, "r") as f:
                    state = json.load(f)
            except:
                pass

        # Calculate expires_at from expires_in so ytmusicapi can use it
        if "expires_in" in token_data and "expires_at" not in token_data:
            token_data["expires_at"] = int(time.time()) + int(token_data["expires_in"])

        state[self.service] = token_data
        with open(OAUTH_STATE_PATH, "w") as f:
            json.dump(state, f, indent=2)

    def get_user_info(self) -> dict:
        token = self.get_token()
        if not token:
            return {}
        req = urllib.request.Request(
            "https://www.googleapis.com/oauth2/v3/userinfo",
            headers={"Authorization": f"Bearer {token['access_token']}"},
        )
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                return json.loads(resp.read())
        except:
            return {}
