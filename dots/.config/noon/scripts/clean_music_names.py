import csv
import re
import sys
import unicodedata
from datetime import datetime
from pathlib import Path

MAX_STEM_LEN = 180

YT_ID_RE = re.compile(r"\s*[\[\(][A-Za-z0-9_\-]{6,25}[\]\)]")

ANY_BRACKET_RE = re.compile(r"[\(\[\{][^\)\]\}]*[\)\]\}]")

ARABIC_NOISE_RE = re.compile(
    r"كلمات|بالكلمات|فيديو كليب|الكليب الرسمي|فيديو مع الكلمات"
    r"|الفيديو الرسمي|بطولة|تتر بداية|تتر نهاية"
    r"|من مسلسل|حفلة\s*\S*|من الاستوديو|نسخة قصيرة"
    r"|الاغنية الرسمية لفيلم\s*\S*"
    r"|التراك المحذوف|بدون موسيقى"
    r"|مع الكلمات|لعشاق الروقان|ابن الاكابر|انتاج شعبيات"
    r"|الموسم السادس|مزيكا صالونات",
    re.UNICODE,
)

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

PLATFORM_RE = re.compile(
    r"\b(?:naghmaty|ceenaija\.com|watertower|tik\s*tok(?:\s*version)?|netflix)\b"
    r"|\b[a-z0-9\-]+\.com\b"
    r"|@\S+",
    re.IGNORECASE,
)

LABEL_RE = re.compile(
    r"\b(?:rotana|nay\s*records?|eka3|mazzika|voice\s*of\s*arabia|melodi|"
    r"platinum\s*records?|good\s*music|artwork\s*station)\b",
    re.IGNORECASE,
)

QUALITY_RE = re.compile(
    r"\b(?:\d{2,3}[Kk](?:bps)?|320|128|256|HQ|HD|4[Kk]|high\s*quality)\b",
    re.IGNORECASE,
)

FEAT_RE = re.compile(
    r"\b(?:featuring|feat\.?|ft\.?|with|x(?=\s+[A-Z\u0600-\u06FF]))\s+",
    re.IGNORECASE,
)

LEADING_TRACK_RE = re.compile(r"^\d{1,3}[\s\.\-–_]+")

TRAILING_NUMBER_RE = re.compile(r"[\s\-–_]+\d{1,3}$")

SERIES_TAG_RE = re.compile(r"\bfok\s*elsehab\s*series\b", re.IGNORECASE)

LEFTOVER_FILM_RE = re.compile(r"لفيلم\s*\S*", re.UNICODE)

PIPE_RE = re.compile(r"\s*[|｜]\s*")
DOTDOT_RE = re.compile(r"\s*\.{2,}\s*|\s*…+\s*")
UNDERSCORE_RE = re.compile(r"\s*_\s*")

LONE_L_RE = re.compile(r"(?<=\s)[lI](?=\s+[\w\u0600-\u06FF])")

YEAR_BRACKET_RE = re.compile(r"[\(\[\{]\s*(?:19|20)\d{2}\s*[\)\]\}]")
YEAR_ANY_RE = re.compile(r"(?<!\d)(?:19|20)\d{2}(?!\d)")

BRACKET_NOISE_RE = re.compile(
    r"[\(\[\{]\s*(?:[Vv]ideo|[Aa]udio|HD|4K|Dina El Wedidi)?\s*[\)\]\}]"
)
EMPTY_BRACKET_RE = re.compile(r"[\(\[\{][^)\]}\w\u0600-\u06FF]*[\)\]\}]")

HASHTAG_RE = re.compile(r"#\S+")

UNICODE_JUNK_RE = re.compile(r"[｜ｘ＂＂＇\uFF00-\uFFEF\u200b-\u200f\u00ad⧸]+")

DOT_SEP_RE = re.compile(r"(?<=[A-Za-z\u0600-\u06FF])\.(?=[A-Za-z\u0600-\u06FF])")

MULTI_DASH_RE = re.compile(r"\s*[-–]{2,}\s*|\s*[-–]\s+[-–]\s*")

MULTI_SPACE_RE = re.compile(r"[ \t]{2,}")
EDGE_JUNK_RE = re.compile(r"^[\s\-–_,.|…!?؟]+|[\s\-–_,.|…!?؟]+$")

SMART_QUOTE_RE = re.compile(r"[\u2018\u2019\u201A\u201B]")
SMART_DQUOTE_RE = re.compile(r"[\u201C\u201D\u201E\u201F]")

HAS_ARABIC_RE = re.compile(r"[\u0600-\u06FF]")


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


def title_case_latin(segment: str) -> str:
    if HAS_ARABIC_RE.search(segment):
        return segment
    minor = {
        "a",
        "an",
        "the",
        "and",
        "but",
        "or",
        "nor",
        "for",
        "so",
        "yet",
        "at",
        "by",
        "in",
        "of",
        "on",
        "to",
        "up",
        "as",
        "is",
        "it",
    }
    words = segment.split()
    result = []
    for i, word in enumerate(words):
        if i == 0 or i == len(words) - 1:
            result.append(word.capitalize())
        elif word.lower() in minor:
            result.append(word.lower())
        else:
            result.append(word.capitalize())
    return " ".join(result)


def normalize_feat(s: str) -> str:
    return FEAT_RE.sub("feat. ", s)


def remove_duplicate_artist(s: str) -> str:
    parts = [p.strip() for p in s.split(" - ")]
    if len(parts) >= 2 and parts[0].lower() == parts[1].lower():
        parts = parts[1:]
        return " - ".join(parts)
    words = s.split()
    n = len(words)
    for length in range(2, n // 2 + 1):
        prefix = " ".join(words[:length]).lower()
        following = " ".join(words[length : length + length]).lower()
        if prefix == following:
            return " ".join(words[length:])
    return s


def remove_duplicate_title(s: str) -> str:
    parts = [p.strip() for p in s.split(" - ")]
    seen: list[str] = []
    for p in parts:
        if p.lower() not in [x.lower() for x in seen]:
            seen.append(p)
    return " - ".join(seen)


def truncate_stem(s: str) -> str:
    if len(s) <= MAX_STEM_LEN:
        return s
    truncated = s[:MAX_STEM_LEN]
    last_space = truncated.rfind(" ")
    if last_space > MAX_STEM_LEN // 2:
        truncated = truncated[:last_space]
    return truncated.rstrip(" -–_,.")


def clean_name(stem: str) -> str:
    s = stem

    s = LEADING_TRACK_RE.sub("", s)
    s = YT_ID_RE.sub("", s)
    s = ANY_BRACKET_RE.sub("", s)
    s = HASHTAG_RE.sub("", s)
    s = strip_emoji(s)
    s = SMART_QUOTE_RE.sub("'", s)
    s = SMART_DQUOTE_RE.sub('"', s)
    s = UNICODE_JUNK_RE.sub(" ", s)
    s = PLATFORM_RE.sub(" ", s)
    s = LABEL_RE.sub(" ", s)
    s = QUALITY_RE.sub(" ", s)
    s = SERIES_TAG_RE.sub(" ", s)
    s = EN_NOISE_RE.sub(" ", s)
    s = ARABIC_NOISE_RE.sub(" ", s)
    s = LEFTOVER_FILM_RE.sub(" ", s)

    for _ in range(4):
        prev = s
        s = BRACKET_NOISE_RE.sub(" ", s)
        s = YEAR_BRACKET_RE.sub(" ", s)
        s = EMPTY_BRACKET_RE.sub(" ", s)
        if s == prev:
            break

    s = YEAR_ANY_RE.sub(" ", s)

    s = PIPE_RE.sub(" - ", s)
    s = DOTDOT_RE.sub(" ", s)
    s = UNDERSCORE_RE.sub(" ", s)
    s = MULTI_DASH_RE.sub(" - ", s)
    s = DOT_SEP_RE.sub(" ", s)

    s = MULTI_SPACE_RE.sub(" ", s)
    s = LONE_L_RE.sub("", s)

    s = normalize_feat(s)
    s = remove_duplicate_artist(s)
    s = remove_duplicate_title(s)

    s = TRAILING_NUMBER_RE.sub("", s)

    s = MULTI_SPACE_RE.sub(" ", s)
    s = EDGE_JUNK_RE.sub("", s)

    parts = [EDGE_JUNK_RE.sub("", p.strip()) for p in s.split(" - ")]
    parts = [p for p in parts if p]
    parts = [title_case_latin(p) for p in parts]
    s = " - ".join(parts)

    s = truncate_stem(s)

    return s


def resolve_collision(target: Path) -> Path:
    if not target.exists():
        return target
    stem = target.stem
    suffix = target.suffix
    parent = target.parent
    counter = 2
    while True:
        candidate = parent / f"{stem}_{counter}{suffix}"
        if not candidate.exists():
            return candidate
        counter += 1


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


def rename_library(
    music_dir: str, dry_run: bool = True, recursive: bool = False
) -> None:
    base = Path(music_dir).expanduser()
    if not base.is_dir():
        print(f"ERROR: '{music_dir}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    glob = base.rglob if recursive else base.glob
    files = sorted(p for p in glob("*") if p.is_file() and is_audio(p))
    print(f"Found {len(files)} audio files in '{base}'\n")

    log_path = base / f"rename_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    log_rows: list[dict] = []

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
                new_path = resolve_collision(new_path)
                original.rename(new_path)
                log_rows.append({"original": str(original), "renamed": str(new_path)})
                renamed += 1
            except Exception as exc:
                print(f"  ERROR: {exc}\n")
                errors += 1
        else:
            renamed += 1

    if not dry_run and log_rows:
        with open(log_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["original", "renamed"])
            writer.writeheader()
            writer.writerows(log_rows)
        print(f"\nLog written to: {log_path.name}")

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
    parser.add_argument(
        "--recursive", action="store_true", help="Recurse into subdirectories."
    )
    args = parser.parse_args()
    rename_library(args.directory, dry_run=not args.apply, recursive=args.recursive)
