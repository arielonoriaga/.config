#!/bin/bash

echo "=== Fixing Wayland Scrolling Flicker Issues ==="

# 1. Apply NVIDIA kernel module configuration
echo "1. Setting up NVIDIA kernel module options..."
if [[ ! -f /etc/modprobe.d/nvidia.conf ]]; then
    echo "Please run this command with sudo to create NVIDIA config:"
    echo "sudo cp ~/.config/nvidia-wayland.conf /etc/modprobe.d/nvidia.conf"
    echo "Then rebuild initramfs: sudo mkinitcpio -P"
fi

# 2. Reload Sway configuration
echo "2. Reloading Sway configuration..."
swaymsg reload

# 3. Update desktop applications database
echo "3. Updating desktop applications..."
update-desktop-database ~/.local/share/applications/

# 4. Test browser configurations
echo "4. Testing browser configurations..."
echo "Use these commands to test different browsers:"
echo "  Regular Brave: brave-browser"
echo "  Optimized Brave: ~/.config/brave-wayland.sh"
echo "  Optimized Firefox: ~/.config/firefox-wayland.sh"

# 5. Check current display configuration
echo "5. Current display setup:"
swaymsg -t get_outputs | jq -r '.[] | "\(.name): \(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh/1000)Hz, adaptive_sync: \(.adaptive_sync_status)"'

echo ""
echo "=== Manual Steps Required ==="
echo "1. Copy NVIDIA configuration:"
echo "   sudo cp ~/.config/nvidia-wayland.conf /etc/modprobe.d/nvidia.conf"
echo ""
echo "2. Rebuild initramfs:"
echo "   sudo mkinitcpio -P"
echo ""
echo "3. Reboot system to apply kernel module changes"
echo ""
echo "4. Test browsers with optimized launchers:"
echo "   ~/.config/brave-wayland.sh"
echo "   ~/.config/firefox-wayland.sh"
echo ""
echo "=== Troubleshooting ==="
echo "If flickering persists, try these additional fixes:"
echo "- Disable hardware acceleration in browser settings"
echo "- Switch to Firefox with native Wayland support"
echo "- Use integrated Intel graphics for browser rendering"
echo "- Reduce refresh rate on external monitor to 60Hz temporarily"