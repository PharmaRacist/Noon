#!/usr/bin/env python3
"""
rename_music.py — Professionalize music filenames (Spotify-style).
Run as dry-run by default; pass --apply to rename for real.
"""

import re
import sys
import unicodedata
from pathlib import Path

# ── YouTube / TikTok IDs ──────────────────────────────────────────────────────
YT_ID_RE = re.compile(r"\s*[\[\(][A-Za-z0-9_\-]{6,25}[\]\)]")

# ── Arabic noise ──────────────────────────────────────────────────────────────
ARABIC_NOISE_RE = re.compile(
    r"كلمات|بالكلمات|فيديو كليب|الكليب الرسمي|فيديو مع الكلمات"
    r"|الفيديو الرسمي|بطولة|تتر بداية|تتر نهاية"
    r"|من مسلسل|حفلة\s*\S*|من الاستوديو|نسخة قصيرة"
    r"|الاغنية الرسمية لفيلم\s*\S*"  # strip "لفيلم X" greedily
    r"|التراك المحذوف|بدون موسيقى"
    r"|مع الكلمات|لعشاق الروقان|ابن الاكابر|انتاج شعبيات"
    r"|الموسم السادس|مزيكا صالونات",
    re.UNICODE,
)

# ── English noise tags ────────────────────────────────────────────────────────
EN_NOISE_RE = re.compile(
    r"\b("
    r"official\s*(?:music\s*)?(?:video|audio|lyric(?:s)?\s*(?:video|clip)?|visualizer|soundtrack)?"
    r"|exclusive\s*(?:music\s*|lyric\s*)?(?:video|clip)?"
    r"|lyric(?:s)?\s*(?:video|clip)"
    r"|audio\s*track|audio(?=\s|$)"
    r"|music\s*video|video\s*clip|video\s*contest\s*winner"
    r"|hd\s*version|remastered(?:\s+\d{4})?"
    r"|eng\s*lyrics?|with\s+lyrics?"
    r"|slowed\s*\+?\s*reverb|slowed(?=\s|$)|reverb(?=\s|$)"
    r"|explicit|short\s*version|visualizer(?=\s|$)"
    r"|soundtrack(?=\s|$)"
    r")\b",
    re.IGNORECASE,
)

# ── Platform / domain noise ───────────────────────────────────────────────────
PLATFORM_RE = re.compile(
    r"\b(?:naghmaty|ceenaija\.com|watertower|tik\s*tok(?:\s*version)?|netflix)\b"
    r"|\b[a-z0-9\-]+\.com\b"
    r"|@\S+",
    re.IGNORECASE,
)

# ── Series label used as suffix tag ──────────────────────────────────────────
SERIES_TAG_RE = re.compile(r"\bfok\s*elsehab\s*series\b", re.IGNORECASE)

# ── "لفيلم <word>" — stray movie ref left after Arabic strip ─────────────────
LEFTOVER_FILM_RE = re.compile(r"لفيلم\s*\S*", re.UNICODE)

# ── Separators → normalise ────────────────────────────────────────────────────
PIPE_RE = re.compile(r"\s*[|｜]\s*")
DOTDOT_RE = re.compile(r"\s*\.{2,}\s*|\s*…+\s*")
UNDERSCORE_RE = re.compile(r"\s*_\s*")

# lone 'l' or 'I' used as separator (artifact of | in original filename)
# must be surrounded by spaces and followed by an Arabic or Latin letter
LONE_L_RE = re.compile(r"(?<=\s)[lI](?=\s+[\w\u0600-\u06FF])")

# ── Years ─────────────────────────────────────────────────────────────────────
# year in brackets
YEAR_BRACKET_RE = re.compile(r"[\(\[\{]\s*(?:19|20)\d{2}\s*[\)\]\}]")
# standalone year not attached to something useful — strip it
YEAR_ANY_RE = re.compile(r"(?<!\d)(?:19|20)\d{2}(?!\d)")

# ── Empty / noise-only brackets ───────────────────────────────────────────────
# parens/brackets with only noise words or whitespace inside
BRACKET_NOISE_RE = re.compile(
    r"[\(\[\{]\s*(?:[Vv]ideo|[Aa]udio|HD|4K|Dina El Wedidi)?\s*[\)\]\}]"
)
EMPTY_BRACKET_RE = re.compile(r"[\(\[\{][^)\]}\w\u0600-\u06FF]*[\)\]\}]")

# ── Hashtags / mentions ───────────────────────────────────────────────────────
HASHTAG_RE = re.compile(r"#\S+")

# ── Unicode junk ──────────────────────────────────────────────────────────────
UNICODE_JUNK_RE = re.compile(r"[｜ｘ＂＂＇\uFF00-\uFFEF\u200b-\u200f\u00ad⧸]+")

# ── Dot word-separator (amr.diab → amr diab), not decimals ───────────────────
DOT_SEP_RE = re.compile(r"(?<=[A-Za-z\u0600-\u06FF])\.(?=[A-Za-z\u0600-\u06FF])")

# ── Multiple / double dashes ──────────────────────────────────────────────────
MULTI_DASH_RE = re.compile(r"\s*[-–]{2,}\s*|\s*[-–]\s+[-–]\s*")

# ── Whitespace / edge junk ────────────────────────────────────────────────────
MULTI_SPACE_RE = re.compile(r"[ \t]{2,}")
EDGE_JUNK_RE = re.compile(r"^[\s\-–_,.|…!?؟]+|[\s\-–_,.|…!?؟]+$")


def strip_emoji(text: str) -> str:
    out = []
    for c in text:
        cp = ord(c)
        if unicodedata.category(c).startswith("So"):
            continue
        if 0x1F000 <= cp <= 0x1FFFF:
            continue
        if 0x2600 <= cp <= 0x27BF:
            continue
        if 0xFE00 <= cp <= 0xFE0F:
            continue
        out.append(c)
    return "".join(out)


def remove_duplicate_artist(s: str) -> str:
    """Remove repeated first segment: 'X X Title' → 'X Title'."""
    parts = [p.strip() for p in s.split(" - ")]
    if len(parts) >= 2 and parts[0].lower() == parts[1].lower():
        parts = parts[1:]
        return " - ".join(parts)
    # Also handle no-dash duplicate prefix: "Dina El Wedidi Dina El Wedidi Title"
    words = s.split()
    n = len(words)
    for length in range(2, n // 2 + 1):
        prefix = " ".join(words[:length]).lower()
        following = " ".join(words[length : length + length]).lower()
        if prefix == following:
            return " ".join(words[length:])
    return s


def clean_name(stem: str) -> str:
    s = stem

    s = YT_ID_RE.sub("", s)
    s = HASHTAG_RE.sub("", s)
    s = strip_emoji(s)
    s = UNICODE_JUNK_RE.sub(" ", s)
    s = PLATFORM_RE.sub(" ", s)
    s = SERIES_TAG_RE.sub(" ", s)
    s = EN_NOISE_RE.sub(" ", s)
    s = ARABIC_NOISE_RE.sub(" ", s)
    s = LEFTOVER_FILM_RE.sub(" ", s)

    # Brackets with noise keywords
    for _ in range(4):
        prev = s
        s = BRACKET_NOISE_RE.sub(" ", s)
        s = YEAR_BRACKET_RE.sub(" ", s)
        s = EMPTY_BRACKET_RE.sub(" ", s)
        if s == prev:
            break

    # Strip all years
    s = YEAR_ANY_RE.sub(" ", s)

    # Separator normalisation
    s = PIPE_RE.sub(" - ", s)
    s = DOTDOT_RE.sub(" ", s)
    s = UNDERSCORE_RE.sub(" ", s)
    s = MULTI_DASH_RE.sub(" - ", s)
    s = DOT_SEP_RE.sub(" ", s)

    # Collapse space then strip lone l/I
    s = MULTI_SPACE_RE.sub(" ", s)
    s = LONE_L_RE.sub("", s)

    s = remove_duplicate_artist(s)
    s = MULTI_SPACE_RE.sub(" ", s)
    s = EDGE_JUNK_RE.sub("", s)

    # Final per-segment cleanup
    parts = [EDGE_JUNK_RE.sub("", p.strip()) for p in s.split(" - ")]
    parts = [p for p in parts if p]
    s = " - ".join(parts)

    return s


def is_audio(path: Path) -> bool:
    return path.suffix.lower() in {
        ".mp3",
        ".m4a",
        ".opus",
        ".flac",
        ".wav",
        ".ogg",
        ".aac",
    }


def rename_library(music_dir: str, dry_run: bool = True) -> None:
    base = Path(music_dir).expanduser()
    if not base.is_dir():
        print(f"ERROR: '{music_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    files = sorted(p for p in base.iterdir() if p.is_file() and is_audio(p))
    print(f"Found {len(files)} audio files in '{base}'\n")

    renamed = skipped = errors = 0

    for original in files:
        new_stem = clean_name(original.stem)
        new_name = new_stem + original.suffix.lower()
        new_path = original.parent / new_name

        if new_name == original.name:
            skipped += 1
            continue

        print(f"  OLD: {original.name}")
        print(f"  NEW: {new_name}")
        print()

        if not dry_run:
            try:
                if new_path.exists():
                    print(f"  SKIP (target exists): {new_name}\n")
                    skipped += 1
                    continue
                original.rename(new_path)
                renamed += 1
            except Exception as exc:
                print(f"  ERROR: {exc}\n")
                errors += 1
        else:
            renamed += 1

    mode = "DRY RUN — no files were changed" if dry_run else "DONE"
    print(f"{'─' * 60}")
    print(f"{mode}")
    print(f"  Would rename : {renamed}" if dry_run else f"  Renamed : {renamed}")
    print(f"  Already clean: {skipped}")
    if errors:
        print(f"  Errors       : {errors}")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Professionalize music filenames.")
    parser.add_argument("directory", nargs="?", default=str(Path.home() / "Music"))
    parser.add_argument("--apply", action="store_true", help="Actually rename files.")
    args = parser.parse_args()
    rename_library(args.directory, dry_run=not args.apply)
