#!/usr/bin/env bash
curr=$(hyprctl activeworkspace -j | jq '.id')

# Determine if $1 is a command or a number
[[ "$1" =~ ^[0-9]+$ ]] && disp="workspace" && target=$1 || { disp=$1; target=$2; }

# Apply paging logic (only if target is a number)
[[ "$target" =~ ^[0-9]+$ ]] && target=$(( (curr - 1) / 10 * 10 + target ))

hyprctl dispatch "$disp" "$target"
