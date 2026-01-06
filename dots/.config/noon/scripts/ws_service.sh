#!/usr/bin/env bash
hyprctl dispatch workspace $(((($(hyprctl activeworkspace -j | jq -r .id) - 1) / 10) * 10 + $1))
