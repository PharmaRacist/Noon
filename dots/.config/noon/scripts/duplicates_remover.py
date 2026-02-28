import argparse
import hashlib
import os
import shutil
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock


def calculate_file_hash(filepath):
    """Generates a SHA-256 hash for a file's content."""
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return filepath, sha256_hash.hexdigest()
    except (OSError, IOError):
        return filepath, None


def collect_files(target_folder, recursive):
    """Collect all file paths to process."""
    if recursive:
        return [
            os.path.join(root, filename)
            for root, dirs, files in os.walk(target_folder)
            for filename in files
        ]
    else:
        return [
            os.path.join(target_folder, f)
            for f in os.listdir(target_folder)
            if os.path.isfile(os.path.join(target_folder, f))
        ]


def handle_duplicate(file_path, dry_run, trash_dir):
    """Delete or move a duplicate file, or just report it in dry-run mode."""
    filename = os.path.basename(file_path)

    if dry_run:
        print(f"[DRY RUN] Would remove: {file_path}")
        return

    if trash_dir:
        # Preserve folder structure inside trash to avoid name collisions
        relative = os.path.relpath(file_path, start=os.path.dirname(file_path))
        dest = os.path.join(trash_dir, filename)

        # Avoid overwriting files already in trash with the same name
        if os.path.exists(dest):
            base, ext = os.path.splitext(filename)
            counter = 1
            while os.path.exists(dest):
                dest = os.path.join(trash_dir, f"{base}_{counter}{ext}")
                counter += 1

        shutil.move(file_path, dest)
        print(f"Trashed duplicate: {filename} → {dest}")
    else:
        os.remove(file_path)
        print(f"Deleted duplicate: {filename}")


def delete_duplicate_files(
    target_folder, recursive=False, workers=8, dry_run=False, trash_dir=None
):
    if not os.path.exists(target_folder):
        print(f"Error: Folder '{target_folder}' does not exist.")
        return

    if trash_dir:
        os.makedirs(trash_dir, exist_ok=True)
        print(f"Trash folder: {trash_dir}")

    if dry_run:
        print("Dry-run mode enabled — no files will be modified.")

    print(
        f"Scanning: {target_folder} {'(recursive) ' if recursive else ''}with {workers} workers...\n"
    )

    files = collect_files(target_folder, recursive)
    hashes_found = {}
    duplicates_count = 0
    lock = Lock()

    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {executor.submit(calculate_file_hash, fp): fp for fp in files}

        for future in as_completed(futures):
            file_path, file_hash = future.result()

            if file_hash is None:
                continue

            with lock:
                if file_hash in hashes_found:
                    print(
                        f"Duplicate found: {os.path.basename(file_path)} (Matches {hashes_found[file_hash]})"
                    )
                    handle_duplicate(file_path, dry_run, trash_dir)
                    duplicates_count += 1
                else:
                    hashes_found[file_hash] = file_path

    action = (
        "would be removed" if dry_run else "deleted" if not trash_dir else "trashed"
    )
    print(f"\nCleanup complete. Total duplicates {action}: {duplicates_count}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Scan a folder and delete duplicate files based on SHA-256 hash.",
        epilog="Examples:\n"
        "  python dedup.py /folder -r\n"
        "  python dedup.py /folder -r --dry-run\n"
        "  python dedup.py /folder -r --trash-dir /tmp/dupes",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument("folder", help="Full path of the folder to scan for duplicates")
    parser.add_argument(
        "-r", "--recursive", action="store_true", help="Recursively scan subfolders"
    )
    parser.add_argument(
        "-w",
        "--workers",
        type=int,
        default=8,
        help="Number of concurrent workers (default: 8)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview duplicates without deleting or moving anything",
    )
    parser.add_argument(
        "--trash-dir",
        metavar="PATH",
        help="Move duplicates to this folder instead of permanently deleting them",
    )

    args = parser.parse_args()
    delete_duplicate_files(
        args.folder,
        recursive=args.recursive,
        workers=args.workers,
        dry_run=args.dry_run,
        trash_dir=args.trash_dir,
    )
