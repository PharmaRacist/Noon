#!/usr/bin/env bash

getdate() { date '+%Y-%m-%d_%H.%M.%S'; }
getaudio() { pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2 | head -n 1; }
getmon() { hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'; }

if pgrep -x "gpu-screen-reco" > /dev/null; then
    killall -SIGINT gpu-screen-recorder
    exit 0
fi

SAVEDIR="$(xdg-user-dir VIDEOS)"
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dir) SAVEDIR="$2"; shift ;;
        --sound|--fullscreen) MODE="$1" ;;
    esac
    shift
done

mkdir -p "$SAVEDIR" && cd "$SAVEDIR" || exit
FILE="recording_$(getdate).mp4"
OPTS="-f 60 -q ultra -tune performance -fallback-cpu-encoding no"

case "$MODE" in
    --sound)
        exec gpu-screen-recorder $OPTS -w "$(slurp)" -a "$(getaudio)" -o "$FILE"
        ;;
    --fullscreen)
        exec gpu-screen-recorder $OPTS -w "$(getmon)" -o "$FILE"
        ;;
    *)
        exec gpu-screen-recorder $OPTS -w "$(slurp)" -o "$FILE"
        ;;
esac
