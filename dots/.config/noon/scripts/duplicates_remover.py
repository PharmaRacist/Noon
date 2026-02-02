import os
import hashlib

def calculate_file_hash(filepath):
    """Generates a SHA-256 hash for a file's content."""
    sha256_hash = hashlib.sha256()
    try:
        with open(filepath, "rb") as f:
            # Read file in chunks to handle large files efficiently
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    except (OSError, IOError):
        return None

def delete_duplicate_files(target_folder):
    if not os.path.exists(target_folder):
        print(f"Error: Folder '{target_folder}' does not exist.")
        return

    hashes_found = {} # Format: {hash: first_file_path}
    duplicates_count = 0

    print(f"Scanning: {target_folder}...")

    for root, dirs, files in os.walk(target_folder):
        for filename in files:
            file_path = os.path.join(root, filename)
            
            file_hash = calculate_file_hash(file_path)
            
            if file_hash is None:
                continue

            if file_hash in hashes_found:
                print(f"Deleting duplicate: {filename} (Matches {hashes_found[file_hash]})")
                os.remove(file_path)
                duplicates_count += 1
            else:
                hashes_found[file_hash] = file_path

    print(f"\nCleanup complete. Total duplicates deleted: {duplicates_count}")

if __name__ == "__main__":
    folder_to_scan = input("Enter the full path of the folder to scan: ").strip()
    delete_duplicate_files(folder_to_scan)
