#!/usr/bin/env bash
DIR="${1:-.}"
OUTPUT="$DIR/.playlist.m3u"
echo "#EXTM3U" > "$OUTPUT"
find "$DIR" -type f -iregex ".*\.\(mp3\|flac\|ogg\|wav\|aac\|m4a\|wma\|opus\|ape\|aiff\)" | sort >> "$OUTPUT"
