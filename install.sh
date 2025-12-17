#!/usr/bin/env bash

set -e

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
N='\033[0m'

# Config
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS="$DIR/dots"
BACKUP="$HOME/.dots_backup_$(date +%Y%m%d_%H%M%S)"
PKGS_FILE="$DIR/packages.txt"
PKGS=()
AUTO=false
DO_BACKUP=false

# Print functions
info() { echo -e "${B}▶${N} $1"; }
ok() { echo -e "${G}✓${N} $1"; }
err() { echo -e "${R}✗${N} $1"; }
warn() { echo -e "${Y}!${N} $1"; }

# Sudo keep-alive
sudo_loop() {
    sudo -v
    while true; do
        sudo -n true
        sleep 50
        kill -0 "$$" || exit
    done 2>/dev/null &
    SUDO_PID=$!
}

cleanup() {
    [ -n "$SUDO_PID" ] && kill "$SUDO_PID" 2>/dev/null
}
trap cleanup EXIT

# Confirm prompt
confirm() {
    [ "$AUTO" = true ] && return 0
    read -p "$1 [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Load packages
load_packages() {
    [ ! -f "$PKGS_FILE" ] && err "packages.txt not found" && exit 1
    
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//;s/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -n "$line" ] && PKGS+=("$line")
    done < "$PKGS_FILE"
    
    [ ${#PKGS[@]} -eq 0 ] && err "No packages in packages.txt" && exit 1
    info "Loaded ${#PKGS[@]} packages"
}

# Ensure yay is installed
ensure_yay() {
    command -v yay &>/dev/null && return 0
    
    info "Installing yay..."
    confirm "Install yay?" || return 1
    
    sudo pacman -S --needed --noconfirm base-devel git
    local tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay" --depth 1 -q
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    
    command -v yay &>/dev/null && ok "yay installed" || { err "yay install failed"; return 1; }
}

# Install packages
install_pkgs() {
    info "Checking packages..."
    ensure_yay || { warn "Continuing without yay"; return; }
    
    local to_install=()
    local not_found=()
    
    for pkg in "${PKGS[@]}"; do
        pacman -Q "$pkg" &>/dev/null && continue
        
        if pacman -Si "$pkg" &>/dev/null || yay -Si "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        else
            not_found+=("$pkg")
        fi
    done
    
    [ ${#not_found[@]} -gt 0 ] && err "Not found: ${not_found[*]}"
    [ ${#to_install[@]} -eq 0 ] && ok "All packages installed" && return
    
    info "To install: ${to_install[*]}"
    
    local ok=0
    local fail=()
    
    for pkg in "${to_install[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            sudo pacman -S --needed --noconfirm "$pkg" && ((ok++)) || fail+=("$pkg")
        else
            yay -S --needed --noconfirm "$pkg" && ((ok++)) || fail+=("$pkg")
        fi
    done
    
    ok "Installed $ok packages"
    [ ${#fail[@]} -gt 0 ] && err "Failed: ${fail[*]}"
}

# Copy dotfiles
copy_dots() {
    info "Copying dotfiles..."
    [ ! -d "$DOTS" ] && err "dots/ not found" && exit 1
    
    local copied=0
    local backed=0
    
    # Copy using rsync or cp -r to preserve structure
    if command -v rsync &>/dev/null; then
        # Backup existing files first
        if [ "$DO_BACKUP" = true ]; then
            mkdir -p "$BACKUP"
            shopt -s dotglob nullglob
            for item in "$DOTS"/*; do
                [ -e "$item" ] || continue
                local name=$(basename "$item")
                
                local dst="$HOME/$name"
                if [ -e "$dst" ]; then
                    cp -a "$dst" "$BACKUP/$name" 2>/dev/null && ((backed++))
                fi
            done
            shopt -u dotglob nullglob
        fi
        
        # Copy with rsync
        rsync -a --exclude='.git' "$DOTS/" "$HOME/"
        copied=$(find "$DOTS" -type f | wc -l)
    else
        # Fallback to cp
        shopt -s dotglob nullglob
        for item in "$DOTS"/*; do
            [ -e "$item" ] || continue
            local name=$(basename "$item")
            
            local dst="$HOME/$name"
            
            # Backup if exists
            if [ "$DO_BACKUP" = true ] && [ -e "$dst" ]; then
                mkdir -p "$BACKUP"
                cp -a "$dst" "$BACKUP/$name" 2>/dev/null && ((backed++))
            fi
            
            # Copy
            cp -rf "$item" "$HOME/"
            if [ -d "$item" ]; then
                copied=$((copied + $(find "$item" -type f | wc -l)))
            else
                ((copied++))
            fi
        done
        shopt -u dotglob nullglob
    fi
    
    ok "Copied $copied files"
    [ $backed -gt 0 ] && info "Backed up to $BACKUP"
}

# Remove dotfiles
remove_dots() {
    info "Removing dotfiles..."
    [ ! -d "$DOTS" ] && err "dots/ not found" && exit 1
    
    local removed=0
    
    shopt -s dotglob nullglob
    for item in "$DOTS"/*; do
        [ -e "$item" ] || continue
        local name=$(basename "$item")
        
        local dst="$HOME/$name"
        
        if [ -d "$item" ]; then
            removed=$((removed + $(find "$dst" -type f 2>/dev/null | wc -l)))
            rm -rf "$dst" 2>/dev/null
        elif [ -f "$dst" ]; then
            rm -f "$dst" && ((removed++))
        fi
    done
    shopt -u dotglob nullglob
    
    ok "Removed $removed files"
}

# Uninstall packages
uninstall_pkgs() {
    local to_remove=()
    for pkg in "${PKGS[@]}"; do
        pacman -Q "$pkg" &>/dev/null && to_remove+=("$pkg")
    done
    
    [ ${#to_remove[@]} -eq 0 ] && info "No packages to remove" && return
    
    warn "Will remove: ${to_remove[*]}"
    confirm "Remove packages?" || return
    
    sudo pacman -Rs --noconfirm "${to_remove[@]}"
    ok "Packages removed"
}

# Main
main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--auto) AUTO=true; shift ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS] COMMAND"
                echo ""
                echo "Commands:"
                echo "  install    Install packages and dotfiles"
                echo "  uninstall  Remove dotfiles and packages"
                echo "  update     Update dotfiles only"
                echo ""
                echo "Options:"
                echo "  -a, --auto  Autopilot mode"
                echo "  -h, --help  Show help"
                exit 0
                ;;
            install|uninstall|update)
                CMD=$1; shift ;;
            *)
                err "Unknown: $1"
                exit 1
                ;;
        esac
    done
    
    [ -z "$CMD" ] && err "No command specified" && exit 1
    
    sudo_loop
    load_packages
    
    case $CMD in
        install)
            if confirm "Install packages?"; then
                install_pkgs
            else
                info "Skipping packages"
            fi
            copy_dots
            ok "Done!"
            ;;
        uninstall)
            remove_dots
            confirm "Also remove packages?" && uninstall_pkgs
            ok "Done!"
            ;;
        update)
            copy_dots
            ok "Done!"
            ;;
    esac
}

main "$@"