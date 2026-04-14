import argparse
import json
import sys
from pathlib import Path


def convert_ansi_to_m3(ansi):
    return {
        "m3background": ansi.get("bg", ansi.get("color0")),
        "m3error": ansi.get("color1"),
        "m3errorContainer": ansi.get("color9"),
        "m3inverseOnSurface": ansi.get("bg", ansi.get("color0")),
        "m3inversePrimary": ansi.get("color12"),
        "m3inverseSurface": ansi.get("fg", ansi.get("color15")),
        "m3onBackground": ansi.get("fg", ansi.get("color15")),
        "m3onError": ansi.get("bg", ansi.get("color0")),
        "m3onErrorContainer": ansi.get("color15"),
        "m3onPrimary": ansi.get("bg", ansi.get("color0")),
        "m3onPrimaryContainer": ansi.get("color15"),
        "m3onPrimaryFixed": ansi.get("color0"),
        "m3onPrimaryFixedVariant": ansi.get("color8"),
        "m3onSecondary": ansi.get("bg", ansi.get("color0")),
        "m3onSecondaryContainer": ansi.get("color15"),
        "m3onSecondaryFixed": ansi.get("color0"),
        "m3onSecondaryFixedVariant": ansi.get("color8"),
        "m3onSurface": ansi.get("fg", ansi.get("color15")),
        "m3onSurfaceVariant": ansi.get("color7"),
        "m3onTertiary": ansi.get("bg", ansi.get("color0")),
        "m3onTertiaryContainer": ansi.get("color15"),
        "m3onTertiaryFixed": ansi.get("color0"),
        "m3onTertiaryFixedVariant": ansi.get("color8"),
        "m3outline": ansi.get("color8"),
        "m3outlineVariant": ansi.get("color7"),
        "m3primary": ansi.get("color4"),
        "m3primaryContainer": ansi.get("color12"),
        "m3primaryFixed": ansi.get("color12"),
        "m3primaryFixedDim": ansi.get("color4"),
        "m3scrim": ansi.get("color0"),
        "m3secondary": ansi.get("color6"),
        "m3secondaryContainer": ansi.get("color14"),
        "m3secondaryFixed": ansi.get("color14"),
        "m3secondaryFixedDim": ansi.get("color6"),
        "m3shadow": ansi.get("color0"),
        "m3surface": ansi.get("bg", ansi.get("color0")),
        "m3surfaceBright": ansi.get("color8"),
        "m3surfaceContainer": ansi.get("color0"),
        "m3surfaceContainerHigh": ansi.get("color8"),
        "m3surfaceContainerHighest": ansi.get("color7"),
        "m3surfaceContainerLow": ansi.get("color0"),
        "m3surfaceContainerLowest": ansi.get("bg", ansi.get("color0")),
        "m3surfaceDim": ansi.get("color8"),
        "m3surfaceTint": ansi.get("color4"),
        "m3surfaceVariant": ansi.get("color8"),
        "m3tertiary": ansi.get("color5"),
        "m3tertiaryContainer": ansi.get("color13"),
        "m3tertiaryFixed": ansi.get("color13"),
        "m3tertiaryFixedDim": ansi.get("color5"),
    }


def main():
    parser = argparse.ArgumentParser(
        description="Convert ANSI 16 JSON palette to Material 3 format."
    )
    parser.add_argument(
        "-i", "--input", required=True, help="Path to input ANSI JSON file"
    )
    parser.add_argument(
        "-o", "--output", required=True, help="Path to save the M3 JSON file"
    )

    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.exists():
        print(f"Error: Input file {args.input} does not exist.")
        sys.exit(1)

    try:
        with open(input_path, "r") as f:
            ansi_data = json.load(f)

        m3_palette = convert_ansi_to_m3(ansi_data)

        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            json.dump(m3_palette, f, indent=2)

        print(f"Successfully converted {args.input} to {args.output}")

    except json.JSONDecodeError:
        print(f"Error: Failed to decode JSON from {args.input}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    main()
