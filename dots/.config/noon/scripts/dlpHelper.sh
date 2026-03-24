#!/usr/bin/env bash
# ADDS METADATA FOR CDN LINKS TO YTDLP
set -euo pipefail

# Argument mapping from BeatsService.downloadDLP
params="$1"   # This is the "format|extra_args" string
url="$2"
dir="$3"
# $4 (name) is ignored because we are fetching the label ourselves now

# Split the params string at the pipe
format="${params%%|*}"
extra_args="${params#*|}"

# 1. Get the direct CDN URL for the specific format
direct_url=$(yt-dlp --no-playlist -f "$format" -g "$url" 2>/dev/null | head -1)

# 2. Get the actual Title/Filename to use as the job label
label=$(yt-dlp --no-playlist --get-filename -o "%(title)s.%(ext)s" "$url" 2>/dev/null)

# 3. Trigger the noon IPC download
# Note: If extra_args contains metadata flags, your 'noon' downloader
# must be capable of processing those flags.
noon ipc call global download \
    "$direct_url" \
    "$dir/$label" \
    "$label" \
    '{"Referer":"https://www.youtube.com","Origin":"https://www.youtube.com"}' \
    -1
