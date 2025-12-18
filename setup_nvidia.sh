#!/usr/bin/env bash

set -e

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
N='\033[0m'

info() { echo -e "${B}▶${N} $1"; }
ok() { echo -e "${G}✓${N} $1"; }
err() { echo -e "${R}✗${N} $1"; }
warn() { echo -e "${Y}!${N} $1"; }

# Use pkexec if available, otherwise sudo
SUDO=$(command -v pkexec &>/dev/null && echo "pkexec" || echo "sudo")

# Sudo keep-alive (only for sudo)
if [ "$SUDO" = "sudo" ]; then
    sudo -v
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_PID=$!
    trap "[ -n '$SUDO_PID' ] && kill '$SUDO_PID' 2>/dev/null" EXIT
fi

MODPROBE_CONF="/etc/modprobe.d/nvidia.conf"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

info "Configuring NVIDIA drivers..."

# Configure modeset
grep -q "options nvidia_drm modeset=1" "$MODPROBE_CONF" 2>/dev/null && ok "Modeset already configured" || {
    echo "options nvidia_drm modeset=1" | $SUDO tee "$MODPROBE_CONF" > /dev/null
    ok "Modeset configured"
}

# Add modules to initramfs
[ ! -f "$MKINITCPIO_CONF" ] && err "mkinitcpio.conf not found" && exit 1

grep -q "^MODULES=.*nvidia" "$MKINITCPIO_CONF" && ok "Modules already configured" || {
    $SUDO cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"
    $SUDO sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINITCPIO_CONF"
    ok "Modules added to initramfs"
}

# Regenerate initramfs
info "Regenerating initramfs..."
$SUDO mkinitcpio -P && ok "Initramfs regenerated" || { err "Failed to regenerate initramfs"; exit 1; }

# Check headers
pacman -Q linux-headers &>/dev/null || pacman -Q linux-lts-headers &>/dev/null && ok "Kernel headers installed" || \
    warn "Kernel headers not found - install with: $SUDO pacman -S linux-headers"

ok "NVIDIA configuration complete"
warn "Reboot required for changes to take effect"

# Reboot prompt
read -p "Reboot now? [y/N]: " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $SUDO reboot