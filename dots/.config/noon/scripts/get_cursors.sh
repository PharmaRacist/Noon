#!/bin/bash
# Find all directories in standard icon paths that contain a "cursors" folder
find /usr/share/icons ~/.local/share/icons ~/.icons -maxdepth 2 -type d -name "cursors" 2>/dev/null | \
rev | cut -d'/' -f2 | rev | sort -u
