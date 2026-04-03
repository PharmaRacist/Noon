import json
import os
import sys


def snake_to_camel(name: str) -> str:
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def add_m3_prefix(key: str) -> str:
    return "m3" + snake_to_camel(key)


def convert_file(path: str) -> None:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    converted = {add_m3_prefix(k): v for k, v in data.items()}

    with open(path, "w", encoding="utf-8") as f:
        json.dump(converted, f, indent=2, ensure_ascii=False)

    print(f"Converted: {path}")


def convert_directory(directory: str) -> None:
    if not os.path.isdir(directory):
        print(f"Error: '{directory}' is not a valid directory.")
        sys.exit(1)

    json_files = [
        os.path.join(directory, f)
        for f in os.listdir(directory)
        if f.endswith(".json")
    ]

    if not json_files:
        print("No JSON files found in the directory.")
        return

    for file_path in json_files:
        convert_file(file_path)

    print(f"\nDone. {len(json_files)} file(s) converted.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python convert_to_m3camel.py <directory>")
        sys.exit(1)

    convert_directory(sys.argv[1])
