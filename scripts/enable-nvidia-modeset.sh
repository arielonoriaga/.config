#!/bin/bash

# NVIDIA DRM Modeset Enabler for Wayland Performance
# This script enables NVIDIA DRM kernel mode setting for better Wayland performance

set -euo pipefail

echo "🔧 Enabling NVIDIA DRM modeset for optimal Wayland performance..."

# Check if running as root for kernel parameter changes
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  Don't run this script as root. It will ask for sudo when needed."
    exit 1
fi

# Check current modeset status
CURRENT_MODESET=$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || echo "N")

if [[ "$CURRENT_MODESET" == "Y" ]]; then
    echo "✅ NVIDIA DRM modeset already enabled"
else
    echo "📝 NVIDIA DRM modeset not enabled. Adding to kernel parameters..."
    
    # Create modprobe configuration
    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf
    
    # Update initramfs
    echo "🔄 Updating initramfs..."
    sudo mkinitcpio -P
    
    echo "⚠️  Reboot required for NVIDIA DRM modeset to take effect"
    echo "   After reboot, run: cat /sys/module/nvidia_drm/parameters/modeset"
    echo "   Should show 'Y' instead of 'N'"
fi

echo "✅ NVIDIA optimization setup complete!"