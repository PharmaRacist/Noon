#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: game_meta.sh --name <game name> --id <game id> [--dir <cover dir>]"
    exit 1
}

GAME_NAME=""
GAME_ID=""
COVER_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/game_covers"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name) GAME_NAME="$2"; shift 2 ;;
        --id)   GAME_ID="$2";   shift 2 ;;
        --dir)  COVER_DIR="$2"; shift 2 ;;
        *) usage ;;
    esac
done

[ -z "$GAME_NAME" ] && { echo '{"error":"--name is required"}'; exit 1; }
[ -z "$GAME_ID" ]   && { echo '{"error":"--id is required"}';   exit 1; }

COVER_PATH="$COVER_DIR/$GAME_ID.jpg"
mkdir -p "$COVER_DIR"

NAME=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$GAME_NAME")

SEARCH=$(curl -sf "https://store.steampowered.com/api/storesearch/?term=$NAME&cc=us&l=en") || {
    echo '{"error":"search failed"}'; exit 1
}

APPID=$(echo "$SEARCH" | python3 -c "
import sys,json
d=json.load(sys.stdin)
items=d.get('items',[])
if items: print(items[0]['id'])
" 2>/dev/null)

[ -z "$APPID" ] && { echo '{"error":"no appid found"}'; exit 1; }

DETAILS=$(curl -sf "https://store.steampowered.com/api/appdetails?appids=$APPID&cc=us&l=en") || {
    echo '{"error":"appdetails failed"}'; exit 1
}

META=$(echo "$DETAILS" | python3 -c "
import sys,json,html
d=json.load(sys.stdin)
key=list(d.keys())[0]
data=d[key].get('data',{})
desc=data.get('short_description') or data.get('detailed_description','')
img=data.get('header_image','')
desc=html.unescape(desc)
print(json.dumps({'appid':key,'desc':desc,'img':img}))
" 2>/dev/null)

[ -z "$META" ] && { echo '{"error":"parse failed"}'; exit 1; }

IMG=$(echo "$META" | python3 -c "import sys,json; print(json.load(sys.stdin).get('img',''))" 2>/dev/null)

[ -n "$IMG" ] && [ ! -f "$COVER_PATH" ] && curl -sfL "$IMG" -o "$COVER_PATH"

echo "$META"
