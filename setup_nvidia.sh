#!/usr/bin/env bash

set -e

SUDO=$(command -v pkexec &>/dev/null && echo "pkexec" || echo "sudo")

if [ "$SUDO" = "sudo" ]; then
    sudo -v
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_PID=$!
    trap "[ -n '$SUDO_PID' ] && kill '$SUDO_PID' 2>/dev/null" EXIT
fi

MODPROBE_CONF="/etc/modprobe.d/nvidia.conf"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

echo "Configuring NVIDIA drivers..."

grep -q "options nvidia_drm modeset=1" "$MODPROBE_CONF" 2>/dev/null && echo "Modeset configured" || {
    echo "options nvidia_drm modeset=1" | $SUDO tee "$MODPROBE_CONF" > /dev/null
    echo "Modeset configured"
}

[ ! -f "$MKINITCPIO_CONF" ] && echo "mkinitcpio.conf not found" && exit 1

grep -q "^MODULES=.*nvidia" "$MKINITCPIO_CONF" && echo "Modules configured" || {
    $SUDO cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.bak"
    $SUDO sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINITCPIO_CONF"
    echo "Modules added"
}

echo "Regenerating initramfs..."
$SUDO mkinitcpio -P && echo "Done" || { echo "Failed"; exit 1; }

pacman -Q linux-headers &>/dev/null || pacman -Q linux-lts-headers &>/dev/null || \
    echo "Install kernel headers: $SUDO pacman -S linux-headers"

echo "Reboot required"

read -p "Reboot now? (y/N): " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && $SUDO reboot
