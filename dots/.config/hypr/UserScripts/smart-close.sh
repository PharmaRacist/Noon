#!/bin/bash
# Smart close: minimize Spotify to tray, kill other windows
class=$(hyprctl activewindow | grep "class:" | cut -d' ' -f2)
if [[ "${class,,}" == "spotify" ]]; then
    hyprctl dispatch movetoworkspacesilent special:spotify
else
    hyprctl dispatch killactive
fi
