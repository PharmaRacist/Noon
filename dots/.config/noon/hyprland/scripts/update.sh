#!/bin/bash
# -----------------------------------------------------
# update-arch.sh — Arch Updater with Flags & New Window
# -----------------------------------------------------

set -e

# Functions
update_system() {
    echo "🔍 Updating Arch Linux system..."
    echo "--------------------------------------------"

    sudo pacman -Syu --noconfirm

    if command -v yay >/dev/null 2>&1; then
        echo
        echo "📦 Updating AUR packages..."
        yay -Syu --noconfirm
    fi

    echo
    echo "✅ System update complete!"
    echo "--------------------------------------------"
}

clean_cache() {
    echo "🧹 Cleaning package cache..."
    sudo pacman -Sc
    echo
    echo "✅ Cache cleanup complete!"
    echo "--------------------------------------------"
}

show_help() {
    echo "Usage: $0 [--update] [--clean]"
    echo
    echo "Options:"
    echo "  --update     Update system packages and AUR packages"
    echo "  --clean      Remove old package caches"
    echo "  --help       Show this help message"
    exit 0
}

# Detect terminal emulator
detect_terminal() {
    if command -v kitty >/dev/null 2>&1; then
        echo "kitty"
    elif command -v alacritty >/dev/null 2>&1; then
        echo "alacritty"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        echo "gnome-terminal"
    elif command -v konsole >/dev/null 2>&1; then
        echo "konsole"
    elif command -v xterm >/dev/null 2>&1; then
        echo "xterm"
    else
        echo ""
    fi
}

# Run command in a new terminal
run_in_terminal() {
    local cmd="$1"
    local term
    term=$(detect_terminal)

    if [ -n "$term" ]; then
        case "$term" in
            kitty|alacritty)
                "$term" -e bash -c "$cmd; echo; echo 'Press Enter to close...'; read"
                ;;
            gnome-terminal)
                "$term" -- bash -c "$cmd; echo; echo 'Press Enter to close...'; read"
                ;;
            konsole)
                "$term" --noclose -e bash -c "$cmd"
                ;;
            xterm)
                "$term" -hold -e bash -c "$cmd"
                ;;
        esac
    else
        echo "⚠️ No supported terminal found. Running in current shell."
        bash -c "$cmd"
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --update)
            run_in_terminal "$(declare -f update_system); update_system"
            ;;
        --clean)
            run_in_terminal "$(declare -f clean_cache); clean_cache"
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "❌ Unknown option: $1"
            show_help
            ;;
    esac
    shift
done

