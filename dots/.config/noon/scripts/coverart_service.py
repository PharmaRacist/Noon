#!/usr/bin/env python3
import hashlib
import os
import sys

import requests
from PIL import Image


def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    url = sys.argv[1]
    cache_dir = (
        sys.argv[2].removeprefix("--cache-dir=")
        if len(sys.argv) > 2
        else "~/.cache/noon/media/coverart"
    )
    cache_dir = os.path.expanduser(cache_dir)

    file_hash = hashlib.md5(url.encode()).hexdigest()
    local_path = os.path.join(cache_dir, f"{file_hash}.jpg")

    # Atomic: check + download + verify
    if os.path.isfile(local_path):
        try:
            with Image.open(local_path) as img:
                img.verify()  # Validates image
            print(local_path)  # Success: output path
            return
        except:
            pass  # Corrupted, redownload

    try:
        os.makedirs(cache_dir, exist_ok=True)
        resp = requests.get(url, timeout=5, stream=True)
        resp.raise_for_status()

        with open(local_path, "wb") as f:
            for chunk in resp.iter_content(8192):
                f.write(chunk)

        with Image.open(local_path) as img:
            img.verify()
        print(local_path)
    except:
        sys.exit(1)


if __name__ == "__main__":
    main()
