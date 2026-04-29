import http.server
import json
import os
import subprocess
import threading
import time
import urllib.parse
import urllib.request
import webbrowser

from requests_oauth2client import OAuth2Client

OAUTH_STATE_PATH = os.path.expanduser("~/.local/state/noon/user/generated/oauth.json")
GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo"
GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
REQUIRED_SCOPES = "openid email profile"


def revoke(client_id: str):
    try:
        with open(OAUTH_STATE_PATH) as f:
            state = json.load(f)
        del state[client_id]
        with open(OAUTH_STATE_PATH, "w") as f:
            json.dump(state, f, indent=2)
    except Exception:
        pass


class NoonAuthenticator:
    def __init__(self, client_id: str, client_secret: str, scopes: str):
        self.cid = client_id
        self.sec = client_secret
        self.scopes = f"{scopes} {REQUIRED_SCOPES}".strip()

        self.client = OAuth2Client(
            token_endpoint=GOOGLE_TOKEN_URL,
            client_id=self.cid,
            client_secret=self.sec,
        )

        token = self.get_token()
        self.accountinfo = token.get("account", {}) if token else {}

    def _load_vault(self) -> dict:
        try:
            with open(OAUTH_STATE_PATH) as f:
                return json.load(f)
        except Exception:
            return {}

    def _save_to_vault(self, token_data):
        os.makedirs(os.path.dirname(OAUTH_STATE_PATH), exist_ok=True)
        if "expires_in" in token_data and "expires_at" not in token_data:
            token_data["expires_at"] = int(time.time()) + int(token_data["expires_in"])
        state = self._load_vault()
        state[self.cid] = token_data
        with open(OAUTH_STATE_PATH, "w") as f:
            json.dump(state, f, indent=2)

    def _post(self, url, data) -> dict:
        resp = urllib.request.urlopen(
            urllib.request.Request(
                url, data=urllib.parse.urlencode(data).encode(), method="POST"
            )
        )
        return json.loads(resp.read())

    def get_token(self) -> dict | None:
        return self._load_vault().get(self.cid)

    def is_authenticated(self) -> bool:
        token = self.get_token()
        return bool(token and "access_token" in token)

    def get_valid_token(self) -> dict | None:
        token = self.get_token()
        if not token:
            return None
        if time.time() >= token.get("expires_at", 0) - 60:
            try:
                new_token = self._post(
                    GOOGLE_TOKEN_URL,
                    {
                        "client_id": self.cid,
                        "client_secret": self.sec,
                        "refresh_token": token["refresh_token"],
                        "grant_type": "refresh_token",
                    },
                )
                new_token.setdefault("refresh_token", token["refresh_token"])
                new_token.setdefault("account", token.get("account", {}))
                self._save_to_vault(new_token)
                return new_token
            except Exception:
                return None
        return token

    def auth_loopback(self, port=8085, interactive=False):
        redirect_uri = f"http://127.0.0.1:{port}"
        code_holder = {}

        class Handler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                code_holder["code"] = urllib.parse.parse_qs(
                    urllib.parse.urlparse(self.path).query
                ).get("code", [None])[0]
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"Authorized. You can close this tab.")

            def log_message(self, *args):
                pass

        server = http.server.HTTPServer(("127.0.0.1", port), Handler)
        threading.Thread(target=server.handle_request, daemon=True).start()

        url = f"{GOOGLE_AUTH_URL}?" + urllib.parse.urlencode(
            {
                "client_id": self.cid,
                "redirect_uri": redirect_uri,
                "response_type": "code",
                "scope": self.scopes,
                "access_type": "offline",
                "prompt": "consent",
            }
        )

        webbrowser.open(url)
        if interactive:
            print(f"[NOON AUTH] Authorize in browser: {url}")
        else:
            subprocess.run(
                ["notify-send", "Noon Auth", "Authorize in the browser window"]
            )

        while "code" not in code_holder:
            time.sleep(0.5)
        server.server_close()

        token_data = self._post(
            GOOGLE_TOKEN_URL,
            {
                "code": code_holder["code"],
                "client_id": self.cid,
                "client_secret": self.sec,
                "redirect_uri": redirect_uri,
                "grant_type": "authorization_code",
            },
        )
        token_data["account"] = self._fetch_accountinfo(token_data["access_token"])
        self._save_to_vault(token_data)
        self.accountinfo = token_data["account"]
        return self.get_token()

    def get_user_info(self) -> dict:
        token = self.get_token()
        if not token:
            return {}
        try:
            with urllib.request.urlopen(
                urllib.request.Request(
                    GOOGLE_USERINFO_URL,
                    headers={"Authorization": f"Bearer {token['access_token']}"},
                ),
                timeout=10,
            ) as resp:
                return json.loads(resp.read())
        except Exception:
            return {}

    def _fetch_accountinfo(self, access_token: str) -> dict:
        try:
            with urllib.request.urlopen(
                urllib.request.Request(
                    GOOGLE_USERINFO_URL,
                    headers={"Authorization": f"Bearer {access_token}"},
                ),
                timeout=10,
            ) as resp:
                info = json.loads(resp.read())
                return {
                    "name": info.get("name", ""),
                    "handler": info.get("email", ""),
                    "image": info.get("picture", ""),
                }
        except Exception:
            return {}
