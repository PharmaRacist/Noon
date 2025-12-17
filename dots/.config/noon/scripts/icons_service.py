#!/usr/bin/env python3
"""
Icon theme manager for GTK and Qt/KDE.
Handles listing, getting, and setting icon themes.

Usage:
    python3 icon-theme-manager.py list              # List all available themes
    python3 icon-theme-manager.py get               # Get current theme for both GTK and Qt
    python3 icon-theme-manager.py set <theme-id>    # Set theme for both GTK and Qt
"""

import json
import os
import subprocess
import sys
from configparser import ConfigParser
from pathlib import Path


def get_icon_themes():
    """Scan for icon themes and return them as a list of dictionaries."""
    themes = []
    search_dirs = [
        "/usr/share/icons",
        os.path.expanduser("~/.local/share/icons"),
        os.path.expanduser("~/.icons"),
    ]

    for base_dir in search_dirs:
        if not os.path.isdir(base_dir):
            continue

        for theme_dir in Path(base_dir).iterdir():
            if not theme_dir.is_dir():
                continue

            index_file = theme_dir / "index.theme"
            if not index_file.exists():
                continue

            try:
                config = ConfigParser()
                config.read(index_file)

                if "Icon Theme" in config:
                    section = config["Icon Theme"]
                    themes.append(
                        {
                            "id": theme_dir.name,
                            "name": section.get("Name", theme_dir.name),
                        }
                    )
            except Exception:
                continue

    # Remove duplicates by id, keeping first occurrence
    seen = set()
    unique_themes = []
    for theme in themes:
        if theme["id"] not in seen:
            seen.add(theme["id"])
            unique_themes.append(theme)

    return sorted(unique_themes, key=lambda x: x["name"].lower())


def get_qt_icon_theme():
    """Get the currently active Qt/KDE icon theme."""
    try:
        # Try kreadconfig6 first (Plasma 6)
        result = subprocess.run(
            ["kreadconfig6", "--group", "Icons", "--key", "Theme"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    try:
        # Fallback to kreadconfig5 (Plasma 5)
        result = subprocess.run(
            ["kreadconfig5", "--group", "Icons", "--key", "Theme"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    return None


def get_gtk_icon_theme():
    """Get the currently active GTK icon theme."""
    # Try GTK 3 settings
    gtk3_config = Path.home() / ".config" / "gtk-3.0" / "settings.ini"
    if gtk3_config.exists():
        try:
            config = ConfigParser()
            config.read(gtk3_config)
            if "Settings" in config and "gtk-icon-theme-name" in config["Settings"]:
                return config["Settings"]["gtk-icon-theme-name"]
        except Exception:
            pass

    # Try gsettings
    try:
        result = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "icon-theme"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        if result.returncode == 0 and result.stdout.strip():
            # gsettings returns quoted strings, remove quotes
            return result.stdout.strip().strip("'\"")
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    return None


def set_qt_icon_theme(theme_id):
    """Set Qt/KDE icon theme."""
    success = False

    # Try kwriteconfig6 first (Plasma 6)
    try:
        result = subprocess.run(
            ["kwriteconfig6", "--group", "Icons", "--key", "Theme", theme_id],
            capture_output=True,
            timeout=2,
        )
        if result.returncode == 0:
            success = True
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    # Try kwriteconfig5 (Plasma 5)
    try:
        result = subprocess.run(
            ["kwriteconfig5", "--group", "Icons", "--key", "Theme", theme_id],
            capture_output=True,
            timeout=2,
        )
        if result.returncode == 0:
            success = True
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    return success


def set_gtk_icon_theme(theme_id):
    """Set GTK icon theme."""
    success = False

    # Update GTK 3 settings.ini
    gtk3_config = Path.home() / ".config" / "gtk-3.0" / "settings.ini"
    gtk3_config.parent.mkdir(parents=True, exist_ok=True)

    try:
        config = ConfigParser()
        if gtk3_config.exists():
            config.read(gtk3_config)

        if "Settings" not in config:
            config["Settings"] = {}

        config["Settings"]["gtk-icon-theme-name"] = theme_id

        with open(gtk3_config, "w") as f:
            config.write(f)
        success = True
    except Exception as e:
        print(f"Failed to write GTK3 config: {e}", file=sys.stderr)

    # Also try gsettings
    try:
        result = subprocess.run(
            ["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", theme_id],
            capture_output=True,
            timeout=2,
        )
        if result.returncode == 0:
            success = True
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    return success


def list_themes():
    """List all available themes."""
    themes = get_icon_themes()
    print(json.dumps(themes, indent=2))


def get_current_themes():
    """Get current icon themes for both Qt and GTK."""
    qt_theme = get_qt_icon_theme()
    gtk_theme = get_gtk_icon_theme()

    result = {"qt": qt_theme, "gtk": gtk_theme}

    print(json.dumps(result, indent=2))


def set_theme(theme_id):
    """Set icon theme for both Qt and GTK."""
    qt_success = set_qt_icon_theme(theme_id)
    gtk_success = set_gtk_icon_theme(theme_id)

    result = {
        "theme": theme_id,
        "qt": qt_success,
        "gtk": gtk_success,
        "success": qt_success or gtk_success,
    }

    print(json.dumps(result, indent=2))
    return 0 if result["success"] else 1


def main():
    if len(sys.argv) < 2:
        print("Usage: icon-theme-manager.py {list|get|set <theme-id>}", file=sys.stderr)
        return 1

    command = sys.argv[1].lower()

    if command == "list":
        list_themes()
        return 0
    elif command == "get":
        get_current_themes()
        return 0
    elif command == "set":
        if len(sys.argv) < 3:
            print("Error: set command requires theme-id", file=sys.stderr)
            return 1
        return set_theme(sys.argv[2])
    else:
        print(f"Error: Unknown command '{command}'", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
