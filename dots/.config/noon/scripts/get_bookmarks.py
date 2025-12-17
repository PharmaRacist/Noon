#!/usr/bin/env python3
"""
Firefox Bookmarks Manager
Extracts bookmarks from Firefox places.sqlite database.

Usage:
    python3 firefox-bookmarks.py list              # List all bookmarks
    python3 firefox-bookmarks.py profiles          # List all Firefox profiles
    python3 firefox-bookmarks.py open <url>        # Open URL in Firefox
    python3 firefox-bookmarks.py fetch-favicons    # Download all favicons to cache
    python3 firefox-bookmarks.py remove <id>       # Remove bookmark by ID
"""

import hashlib
import json
import os
import sqlite3
import subprocess
import sys
import urllib.request
from pathlib import Path


def get_favicon_cache_path():
    """Get the favicon cache directory."""
    cache_dir = Path.home() / ".cache" / "quickshell" / "media" / "favicons"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir


def get_favicon_filename(url):
    """Generate a unique filename for a favicon based on URL."""
    # Create a hash of the URL for a unique filename
    url_hash = hashlib.md5(url.encode()).hexdigest()[:16]

    # Extract domain for a readable name
    try:
        from urllib.parse import urlparse

        parsed = urlparse(url)
        domain = parsed.netloc.replace("www.", "").replace(".", "_")
        return f"{domain}_{url_hash}.png"
    except:
        return f"favicon_{url_hash}.png"


def download_favicon(url, cache_path):
    """Download favicon for a URL and save to cache."""
    try:
        from urllib.parse import urlparse

        parsed = urlparse(url)
        domain = parsed.netloc or parsed.path

        if not domain:
            return None

        # Try multiple favicon sources
        favicon_urls = [
            f"https://www.google.com/s2/favicons?domain={domain}&sz=32",
            f"https://{domain}/favicon.ico",
            f"https://icons.duckduckgo.com/ip3/{domain}.ico",
        ]

        for favicon_url in favicon_urls:
            try:
                req = urllib.request.Request(
                    favicon_url, headers={"User-Agent": "Mozilla/5.0"}
                )
                with urllib.request.urlopen(req, timeout=5) as response:
                    if response.status == 200:
                        favicon_data = response.read()
                        if len(favicon_data) > 0:
                            cache_path.write_bytes(favicon_data)
                            return str(cache_path)
            except:
                continue

        return None
    except Exception as e:
        return None


def fetch_all_favicons():
    """Download favicons for all bookmarks."""
    try:
        profile_path = find_active_profile()
        if not profile_path:
            print(json.dumps({"error": "No Firefox profile found"}, indent=2))
            sys.exit(1)

        bookmarks = get_bookmarks(profile_path)
        cache_dir = get_favicon_cache_path()

        results = {"total": len(bookmarks), "downloaded": 0, "cached": 0, "failed": 0}

        for bookmark in bookmarks:
            url = bookmark.get("url")
            if not url:
                results["failed"] += 1
                continue

            filename = get_favicon_filename(url)
            cache_path = cache_dir / filename

            # Skip if already cached
            if cache_path.exists():
                results["cached"] += 1
                continue

            # Download favicon
            if download_favicon(url, cache_path):
                results["downloaded"] += 1
            else:
                results["failed"] += 1

        print(json.dumps(results, indent=2))
    except Exception as e:
        print(json.dumps({"error": str(e)}, indent=2))
        sys.exit(1)


def find_all_firefox_profiles():
    """Find all Firefox profile directories."""
    if sys.platform == "win32":
        profile_base = (
            Path(os.environ.get("APPDATA", "")) / "Mozilla" / "Firefox" / "Profiles"
        )
    elif sys.platform == "darwin":
        profile_base = (
            Path.home() / "Library" / "Application Support" / "Firefox" / "Profiles"
        )
    else:  # Linux and other Unix-like
        profile_base = Path.home() / ".mozilla" / "firefox"

    if not profile_base.exists():
        return []

    # Find all profile directories
    profiles = [
        p for p in profile_base.iterdir() if p.is_dir() and not p.name.startswith(".")
    ]
    return profiles


def find_active_profile():
    """Find the profile that contains places.sqlite (the active one)."""
    profiles = find_all_firefox_profiles()

    for profile in profiles:
        places_db = profile / "places.sqlite"
        if places_db.exists():
            return profile

    return None


def get_bookmarks(profile_path):
    """Extract bookmarks from Firefox places.sqlite database."""
    places_db = profile_path / "places.sqlite"

    if not places_db.exists():
        raise FileNotFoundError(f"places.sqlite not found at {places_db}")

    # Try to connect directly with read-only mode first
    try:
        # Use immutable mode to read even when Firefox is running
        conn = sqlite3.connect(f"file:{places_db}?immutable=1", uri=True)
        cursor = conn.cursor()

        # First check what tables exist
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row[0] for row in cursor.fetchall()]

        # Basic query for bookmarks
        query = """
        SELECT
            moz_bookmarks.id,
            moz_bookmarks.title,
            moz_places.url,
            moz_bookmarks.dateAdded,
            moz_bookmarks.lastModified,
            moz_bookmarks.parent
        FROM moz_bookmarks
        LEFT JOIN moz_places ON moz_bookmarks.fk = moz_places.id
        WHERE moz_bookmarks.type = 1 AND moz_places.url IS NOT NULL
        ORDER BY moz_bookmarks.id
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        bookmarks = []
        for row in rows:
            url = row[2]

            # Get cached favicon path
            favicon_local = ""
            if url:
                cache_dir = get_favicon_cache_path()
                filename = get_favicon_filename(url)
                cache_path = cache_dir / filename
                if cache_path.exists():
                    favicon_local = f"file://{cache_path}"

            # Extract domain for Google favicon fallback
            favicon_fallback = ""
            if url:
                try:
                    from urllib.parse import urlparse

                    parsed = urlparse(url)
                    domain = parsed.netloc or parsed.path
                    if domain:
                        favicon_fallback = (
                            f"https://www.google.com/s2/favicons?domain={domain}&sz=32"
                        )
                except:
                    pass

            bookmark = {
                "id": row[0],
                "title": row[1] if row[1] else "Untitled",
                "url": url,
                "date_added": row[3],
                "last_modified": row[4],
                "parent_id": row[5],
                "favicon_local": favicon_local,
                "favicon_url": favicon_fallback,
                "has_cached_favicon": bool(favicon_local),
            }
            bookmarks.append(bookmark)

        conn.close()
        return bookmarks

    except sqlite3.OperationalError as e:
        # If immutable mode fails, try with a temporary copy
        import shutil

        temp_db = profile_path / "places_temp.sqlite"

        try:
            shutil.copy2(places_db, temp_db)
            db_to_use = temp_db
        except (PermissionError, OSError):
            # Last resort: try read-only mode
            db_to_use = places_db

        try:
            conn = sqlite3.connect(f"file:{db_to_use}?mode=ro", uri=True)
            cursor = conn.cursor()

            query = """
            SELECT
                moz_bookmarks.id,
                moz_bookmarks.title,
                moz_places.url,
                moz_bookmarks.dateAdded,
                moz_bookmarks.lastModified,
                moz_bookmarks.parent
            FROM moz_bookmarks
            LEFT JOIN moz_places ON moz_bookmarks.fk = moz_places.id
            WHERE moz_bookmarks.type = 1 AND moz_places.url IS NOT NULL
            ORDER BY moz_bookmarks.id
            """

            cursor.execute(query)
            rows = cursor.fetchall()

            bookmarks = []
            for row in rows:
                url = row[2]

                # Get cached favicon path
                favicon_local = ""
                if url:
                    cache_dir = get_favicon_cache_path()
                    filename = get_favicon_filename(url)
                    cache_path = cache_dir / filename
                    if cache_path.exists():
                        favicon_local = f"file://{cache_path}"

                # Extract domain for Google favicon fallback
                favicon_fallback = ""
                if url:
                    try:
                        from urllib.parse import urlparse

                        parsed = urlparse(url)
                        domain = parsed.netloc or parsed.path
                        if domain:
                            favicon_fallback = f"https://www.google.com/s2/favicons?domain={domain}&sz=32"
                    except:
                        pass

                bookmark = {
                    "id": row[0],
                    "title": row[1] if row[1] else "Untitled",
                    "url": url,
                    "date_added": row[3],
                    "last_modified": row[4],
                    "parent_id": row[5],
                    "favicon_local": favicon_local,
                    "favicon_url": favicon_fallback,
                    "has_cached_favicon": bool(favicon_local),
                }
                bookmarks.append(bookmark)

            conn.close()
            return bookmarks
        finally:
            # Clean up temporary database
            if db_to_use != places_db and db_to_use.exists():
                try:
                    db_to_use.unlink()
                except:
                    pass


def list_profiles():
    """List all Firefox profiles."""
    profiles = find_all_firefox_profiles()

    result = []
    for profile in profiles:
        places_db = profile / "places.sqlite"
        result.append(
            {
                "name": profile.name,
                "path": str(profile),
                "has_places": places_db.exists(),
            }
        )

    print(json.dumps(result, indent=2))


def list_bookmarks():
    """List all bookmarks from active profile."""
    profile_path = find_active_profile()

    if not profile_path:
        print(json.dumps({"error": "No Firefox profile found"}, indent=2))
        sys.exit(1)

    try:
        bookmarks = get_bookmarks(profile_path)
        print(json.dumps(bookmarks, indent=2))
    except Exception as e:
        print(json.dumps({"error": str(e)}, indent=2))
        sys.exit(1)


def open_url(url):
    """Open URL in existing Firefox instance or new tab."""
    try:
        # Try xdg-open first (works better with existing Firefox instances)
        result = subprocess.run(
            ["xdg-open", url], check=True, capture_output=True, timeout=5
        )
        print(json.dumps({"success": True, "url": url}, indent=2))
    except subprocess.TimeoutExpired:
        # Timeout is okay - the browser opened
        print(json.dumps({"success": True, "url": url}, indent=2))
    except subprocess.CalledProcessError:
        # Fallback to firefox directly
        try:
            subprocess.Popen(
                ["firefox", url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            print(json.dumps({"success": True, "url": url}, indent=2))
        except Exception as e:
            print(json.dumps({"success": False, "error": str(e)}, indent=2))
            sys.exit(1)
    except FileNotFoundError:
        # xdg-open not found, try firefox directly
        try:
            subprocess.Popen(
                ["firefox", url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
            print(json.dumps({"success": True, "url": url}, indent=2))
        except Exception as e:
            print(json.dumps({"success": False, "error": str(e)}, indent=2))
            sys.exit(1)
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}, indent=2))
        sys.exit(1)


def remove_bookmark(bookmark_id):
    """Remove a bookmark by ID from Firefox database."""
    try:
        profile_path = find_active_profile()
        if not profile_path:
            print(
                json.dumps(
                    {"success": False, "error": "No Firefox profile found"}, indent=2
                )
            )
            sys.exit(1)

        places_db = profile_path / "places.sqlite"
        if not places_db.exists():
            print(
                json.dumps(
                    {"success": False, "error": "places.sqlite not found"}, indent=2
                )
            )
            sys.exit(1)

        # Connect with write access
        conn = sqlite3.connect(str(places_db))
        cursor = conn.cursor()

        # Check if bookmark exists
        cursor.execute(
            "SELECT id, title FROM moz_bookmarks WHERE id = ?", (bookmark_id,)
        )
        result = cursor.fetchone()

        if not result:
            conn.close()
            print(
                json.dumps(
                    {"success": False, "error": f"Bookmark {bookmark_id} not found"},
                    indent=2,
                )
            )
            sys.exit(1)

        bookmark_title = result[1] or "Untitled"

        # Delete the bookmark
        cursor.execute("DELETE FROM moz_bookmarks WHERE id = ?", (bookmark_id,))
        conn.commit()
        conn.close()

        print(
            json.dumps(
                {
                    "success": True,
                    "id": bookmark_id,
                    "title": bookmark_title,
                    "message": f"Bookmark '{bookmark_title}' removed successfully",
                },
                indent=2,
            )
        )

    except sqlite3.OperationalError as e:
        error_msg = str(e)
        if "locked" in error_msg.lower():
            print(
                json.dumps(
                    {
                        "success": False,
                        "error": "Database is locked. Please close Firefox and try again.",
                    },
                    indent=2,
                )
            )
        else:
            print(json.dumps({"success": False, "error": error_msg}, indent=2))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}, indent=2))
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print(
            "Usage: firefox-bookmarks.py {list|profiles|open <url>|fetch-favicons|remove <id>}",
            file=sys.stderr,
        )
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == "list":
        list_bookmarks()
    elif command == "profiles":
        list_profiles()
    elif command == "open":
        if len(sys.argv) < 3:
            print("Error: open command requires URL", file=sys.stderr)
            sys.exit(1)
        open_url(sys.argv[2])
    elif command == "fetch-favicons":
        fetch_all_favicons()
    elif command == "remove":
        if len(sys.argv) < 3:
            print("Error: remove command requires bookmark ID", file=sys.stderr)
            sys.exit(1)
        try:
            bookmark_id = int(sys.argv[2])
            remove_bookmark(bookmark_id)
        except ValueError:
            print(
                json.dumps({"success": False, "error": "Invalid bookmark ID"}, indent=2)
            )
            sys.exit(1)
    else:
        print(f"Error: Unknown command '{command}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
