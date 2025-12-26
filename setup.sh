#!/usr/bin/env bash

DIR="/opt/noon"
DOTS="$DIR/dots"
NOON_REPO="Noon_Repo"
NOON_REPO_URL="https://pharmaracist.github.io/Noon_Repo/\$arch"
GITHUB_REPO="https://github.com/PharmaRacist/Noon"

info() { echo "▶ $1"; }
ok() { echo "✓ $1"; }
err() { echo "✗ $1"; }
warn() { echo "! $1"; }

# Add repository to pacman.conf
add_repo() {
    info "Checking Noon_Repo..."
    
    if grep -q "\[$NOON_REPO\]" /etc/pacman.conf; then
        ok "Noon_Repo already configured"
    else
        info "Adding Noon_Repo to pacman.conf..."
        sudo tee -a /etc/pacman.conf > /dev/null << EOF

[$NOON_REPO]
SigLevel = Optional TrustAll
Server = $NOON_REPO_URL
EOF
        ok "Noon_Repo added"
    fi
    
    info "Syncing package database..."
    sudo pacman -Sy
    ok "Repository synced"
}

# Remove repo
remove_repo() {
    info "Removing Noon_Repo from pacman.conf..."
    
    sudo sed -i "/^\[$NOON_REPO\]/,/^Server = /d" /etc/pacman.conf
    
    ok "Noon_Repo removed"
    sudo pacman -Sy
}

# Update from GitHub
update_from_github() {
    info "Checking for updates from GitHub..."
    
    if [ ! -d "$DIR/.git" ]; then
        warn "Not a git repository"
        return 1
    fi
    
    if ! command -v git &>/dev/null; then
        warn "git not installed"
        return 1
    fi
    
    info "Fetching from $GITHUB_REPO..."
    git -C "$DIR" fetch origin 2>/dev/null || {
        err "Failed to fetch from remote"
        return 1
    }
    
    local local_commit=$(git -C "$DIR" rev-parse HEAD 2>/dev/null)
    local remote_commit=$(git -C "$DIR" rev-parse origin/main 2>/dev/null || git -C "$DIR" rev-parse origin/master 2>/dev/null)
    
    if [ -z "$local_commit" ] || [ -z "$remote_commit" ]; then
        err "Failed to get commit information"
        return 1
    fi
    
    if [ "$local_commit" = "$remote_commit" ]; then
        ok "Already up to date"
        return 1
    fi
    
    local branch=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    local commits_behind=$(git -C "$DIR" rev-list --count HEAD..origin/$branch 2>/dev/null || echo "0")
    
    info "Found $commits_behind new commit(s)"
    
    info "Pulling updates..."
    if git -C "$DIR" pull origin "$branch" 2>/dev/null; then
        ok "Updated successfully from GitHub"
        return 0
    else
        err "Failed to pull updates"
        return 1
    fi
}

# Update packages
update_packages() {
    info "Updating Noon packages..."
    
    sudo pacman -Sy
    
    local packages=(noon-main noon-nvidia)
    local to_update=()
    
    for pkg in "${packages[@]}"; do
        if pacman -Q "$pkg" &>/dev/null; then
            to_update+=("$pkg")
        fi
    done
    
    if [ ${#to_update[@]} -eq 0 ]; then
        ok "No Noon packages installed"
        return 0
    fi
    
    sudo pacman -S --needed "${to_update[@]}"
    ok "Packages updated"
}

# Ensure stow is installed
ensure_stow() {
    if ! command -v stow &>/dev/null; then
        info "Installing stow..."
        sudo pacman -S --needed --noconfirm stow
    fi
}

# Symlink dotfiles using stow
link_dots() {
    info "Symlinking dotfiles with GNU Stow..."
    
    ensure_stow
    
    # Fix permissions first
    [ -d "$DOTS" ] && sudo chown -R $USER:$USER "$DOTS" 2>/dev/null
    
    # Use stow to create symlinks
    cd "$DOTS"
    stow -v -t "$HOME" . 2>&1 | grep -v "BUG in find_stowed_path" || true
    
    ok "Dotfiles symlinked"
}

# Remove dotfile symlinks using stow
unlink_dots() {
    info "Removing dotfile symlinks..."
    
    if ! command -v stow &>/dev/null; then
        warn "stow not installed, skipping"
        return
    fi
    
    cd "$DOTS"
    stow -v -D -t "$HOME" . 2>&1 | grep -v "BUG in find_stowed_path" || true
    
    ok "Dotfile symlinks removed"
}

case "${1:-install}" in
    install)
        add_repo
        link_dots
        echo ""
        ok "Installation complete!"
        echo "   Repository: Noon_Repo"
        echo "   Run: sudo pacman -S noon-main"
        ;;
    
    update)
        echo ""
        if update_from_github; then
            echo ""
            update_packages
            echo ""
            ok "Update complete! Dotfiles are auto-updated via symlinks"
        else
            echo ""
            warn "No GitHub updates available"
            echo ""
            update_packages
            echo ""
            ok "Packages updated"
        fi
        ;;
    
    remove)
        unlink_dots
        remove_repo
        ;;
    
    *)
        echo "Usage: noon {install|update|remove}"
        echo ""
        echo "Commands:"
        echo "  install  - Add Noon_Repo and symlink dotfiles"
        echo "  update   - Update from GitHub and upgrade packages"
        echo "  remove   - Remove symlinks and Noon_Repo"
        exit 1
        ;;
esac

