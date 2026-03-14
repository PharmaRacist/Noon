import os
import sys
from mutagen.id3 import ID3, ID3NoHeaderError


def rename_mp3s(directory):
    if not os.path.isdir(directory):
        print(f"Error: '{directory}' is not a valid directory.")
        sys.exit(1)

    mp3_files = [f for f in os.listdir(directory) if f.lower().endswith(".mp3")]

    if not mp3_files:
        print("No MP3 files found in the directory.")
        return

    for filename in mp3_files:
        filepath = os.path.join(directory, filename)

        try:
            tags = ID3(filepath)
            title = tags.get("TIT2")

            if not title:
                print(f"  [SKIP] '{filename}' — no title tag found.")
                continue

            # Sanitize title for use as a filename
            safe_title = "".join(
                c for c in str(title) if c not in r'\/:*?"<>|'
            ).strip()

            if not safe_title:
                print(f"  [SKIP] '{filename}' — title is empty after sanitizing.")
                continue

            new_filename = safe_title + ".mp3"
            new_filepath = os.path.join(directory, new_filename)

            if filepath == new_filepath:
                print(f"  [SAME] '{filename}' — already named correctly.")
                continue

            # Avoid overwriting an existing file
            if os.path.exists(new_filepath):
                print(f"  [SKIP] '{filename}' — target '{new_filename}' already exists.")
                continue

            os.rename(filepath, new_filepath)
            print(f"  [OK]   '{filename}'  →  '{new_filename}'")

        except ID3NoHeaderError:
            print(f"  [SKIP] '{filename}' — no ID3 tags found.")
        except Exception as e:
            print(f"  [ERR]  '{filename}' — {e}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python rename_mp3.py <directory>")
        sys.exit(1)

    rename_mp3s(sys.argv[1])
