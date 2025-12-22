#!/bin/bash

ACTION=$1
MODE=$2
STATE_FILE="$HOME/.local/state/noon/states.json"
mkdir -p "$(dirname "$STATE_FILE")"
[ -f "$STATE_FILE" ] || echo '{}' > "$STATE_FILE"

get_controller() {
    command -v powerprofilesctl >/dev/null && echo power-profiles-daemon && return
    command -v tlp >/dev/null && echo tlp && return
    echo none
}

update_json() {
    local ctrl="$1" mode="$2" modes="$3"
    jq --arg ctrl "$ctrl" --arg m "$mode" --argjson mds "$modes" \
       '.services.power.controller=$ctrl | .services.power.mode=$m | .services.power.modes=$mds' \
       "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
}

case "$ACTION" in
    update)
        CTRL=$(get_controller)
        case "$CTRL" in
            power-profiles-daemon)
                MODE=$(powerprofilesctl get 2>/dev/null || echo balanced)
                MODES='["power-saver","balanced","performance"]'
                ;;
            tlp)
                MODE=$(pkexec tlp-stat -m 2>/dev/null | awk -F'/' '{print tolower($1)}')
                [[ $MODE =~ perf ]] && MODE=performance
                [[ $MODE =~ save ]] && MODE=power-saver
                [[ -z $MODE ]] && MODE=balanced
                MODES='["power-saver","balanced","performance"]'
                ;;
            *)
                MODE=power-saver
                MODES='["power-saver"]'
                ;;
        esac
        update_json "$CTRL" "$MODE" "$MODES"
        ;;
    set)
        CTRL=$(get_controller)
        case "$CTRL" in
            tlp)
                NEW=$(pkexec bash -c "tlp '$MODE' >/dev/null 2>&1 && tlp-stat -m 2>/dev/null" | awk -F'/' '{print tolower($1)}')
                [[ $NEW =~ perf ]] && NEW=performance
                [[ $NEW =~ save ]] && NEW=power-saver
                [[ -z $NEW ]] && NEW=$MODE
                update_json tlp "$NEW" '["power-saver","balanced","performance"]'
                ;;
            power-profiles-daemon)
                powerprofilesctl set "$MODE" && NEW=$(powerprofilesctl get 2>/dev/null || echo "$MODE")
                update_json power-profiles-daemon "$NEW" '["power-saver","balanced","performance"]'
                ;;
        esac
        ;;
    status)
        "$0" update
        jq -r '.services.power | "\(.controller)|\(.mode)|\(.modes|join(","))"' "$STATE_FILE"
        ;;
    *)
        echo "Usage: $0 <update|set|status> [mode]"
        exit 1
        ;;
esac
