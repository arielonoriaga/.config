#!/bin/bash

# Brave Browser Performance Optimization Script for Arch + Sway + NVIDIA/Intel Hybrid
# This script optimizes Brave browser performance on Wayland with hybrid graphics

set -euo pipefail

echo "🚀 Optimizing Brave browser performance for Sway + Wayland + Hybrid Graphics..."

# Kill existing Brave processes
echo "📦 Stopping Brave browser..."
pkill -f brave || true
sleep 2

# Set optimal environment variables for current session
echo "⚙️  Setting environment variables..."
export WLR_DRM_DEVICES="/dev/dri/card0:/dev/dri/card1"
export WLR_NO_HARDWARE_CURSORS=1
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_RENDERER=vulkan

# Check if NVIDIA modules are loaded
echo "🔍 Checking NVIDIA drivers..."
if ! lsmod | grep -q nvidia; then
    echo "⚠️  Warning: NVIDIA drivers not loaded. Loading..."
    sudo modprobe nvidia nvidia_drm nvidia_uvm nvidia_modeset
fi

# Enable NVIDIA DRM modeset if not already enabled
echo "🎮 Enabling NVIDIA DRM modeset..."
if ! cat /sys/module/nvidia_drm/parameters/modeset | grep -q Y; then
    echo "⚠️  NVIDIA DRM modeset not enabled. Add 'nvidia_drm.modeset=1' to kernel parameters"
    echo "   Run: sudo nano /etc/default/grub"
    echo "   Add to GRUB_CMDLINE_LINUX: nvidia_drm.modeset=1"
    echo "   Then: sudo grub-mkconfig -o /boot/grub/grub.cfg"
fi

# Verify hardware acceleration capabilities
echo "🧪 Testing hardware acceleration..."
if command -v vainfo &> /dev/null; then
    echo "VAAPI support:"
    vainfo 2>/dev/null | grep -E "(VAEntrypoint|VAConfigAttrib)" || echo "VAAPI not available"
else
    echo "⚠️  vainfo not installed. Install with: sudo pacman -S libva-utils"
fi

# Check Brave hardware acceleration settings
echo "🌐 Launch Brave with optimized flags..."
echo "   Visit brave://gpu/ to verify hardware acceleration is enabled"
echo "   Visit brave://flags/ and enable:"
echo "   - #enable-gpu-rasterization"
echo "   - #enable-zero-copy"
echo "   - #enable-accelerated-video-decode"
echo "   - #enable-accelerated-video-encode"

# Reload Sway configuration
echo "🔄 Reloading Sway configuration..."
swaymsg reload

# Start Brave with optimized flags
echo "🚀 Starting Brave with optimized configuration..."
brave --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,UseOzonePlatform,WebRTCPipeWireCapturer \
      --ozone-platform=wayland \
      --enable-gpu-rasterization \
      --enable-zero-copy \
      --enable-hardware-overlays \
      --ignore-gpu-blacklist \
      --disable-gpu-sandbox \
      --enable-oop-rasterization \
      --canvas-oop-rasterization \
      --enable-raw-draw \
      --disable-features=UseChromeOSDirectVideoDecoder \
      --enable-accelerated-video-decode \
      --enable-accelerated-video-encode \
      --use-gl=desktop \
      --disable-software-rasterizer &

echo "✅ Brave optimization complete!"
echo ""
echo "🔧 Additional optimizations you can try:"
echo "1. Visit brave://settings/ → Advanced → System → Hardware acceleration"
echo "2. Visit brave://flags/ → Search 'smooth scrolling' → Enable"
echo "3. Visit brave://flags/ → Search 'experimental web platform features' → Enable"
echo "4. Consider using Intel GPU for display and NVIDIA for compute-heavy tasks"
echo ""
echo "📊 Test scrolling performance on heavy websites like:"
echo "   - https://news.ycombinator.com"
echo "   - https://reddit.com"
echo "   - Any long-form article with images"