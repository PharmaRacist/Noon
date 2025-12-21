#!/bin/bash
# power_service.sh

CONTROLLER=$1
ACTION=$2
MODE=$3

case "$CONTROLLER" in
    tlp)
        if [ "$ACTION" = "get" ]; then
            tlp-stat -s 2>/dev/null | grep "Mode" | awk '{print $3}'
        else
            pkexec tlp $MODE
        fi
        ;;
    power-profiles-daemon)
        if [ "$ACTION" = "get" ]; then
            powerprofilesctl get
        else
            powerprofilesctl set $MODE
        fi
        ;;
    auto-cpufreq)
        if [ "$ACTION" = "get" ]; then
            state=$(pkexec auto-cpufreq --stats 2>/dev/null | grep "Battery state" | awk '{print $NF}')
            [ "$state" = "discharging" ] && echo "bat" || echo "ac"
        else
            # auto-cpufreq doesn't support manual mode switching
            echo "auto-cpufreq manages modes automatically" >&2
            exit 1
        fi
        ;;
    *)
        echo "Unknown controller: $CONTROLLER" >&2
        exit 1
        ;;
esac
