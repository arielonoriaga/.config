#!/bin/bash

echo "🔧 Fixing screen sharing for Sway + Wayland..."

# Update package database first
echo "🔄 Updating package database..."
sudo pacman -Sy

# Install required packages
echo "📦 Installing screen capture tools..."
sudo pacman -S grim slurp wf-recorder xdg-desktop-portal-wlr --noconfirm

# Check if installation was successful
if ! command -v grim &> /dev/null; then
    echo "❌ grim installation failed, trying AUR..."
    if command -v yay &> /dev/null; then
        yay -S grim --noconfirm
    elif command -v paru &> /dev/null; then
        paru -S grim --noconfirm
    else
        echo "❌ No AUR helper found. Please install grim manually:"
        echo "   sudo pacman -S grim"
        exit 1
    fi
fi

# Restart desktop portal services
echo "🔄 Restarting desktop portal services..."
systemctl --user stop xdg-desktop-portal-wlr
systemctl --user stop xdg-desktop-portal
sleep 2
systemctl --user start xdg-desktop-portal
systemctl --user start xdg-desktop-portal-wlr

# Test screen capture
echo "🧪 Testing screen capture..."
if command -v grim &> /dev/null; then
    echo "✅ grim installed successfully"
else
    echo "❌ grim installation failed"
    exit 1
fi

if command -v slurp &> /dev/null; then
    echo "✅ slurp installed successfully"
else
    echo "❌ slurp installation failed" 
    exit 1
fi

# Check portal services
echo "🔍 Checking portal services..."
if systemctl --user is-active --quiet xdg-desktop-portal; then
    echo "✅ xdg-desktop-portal is running"
else
    echo "❌ xdg-desktop-portal failed to start"
fi

if systemctl --user is-active --quiet xdg-desktop-portal-wlr; then
    echo "✅ xdg-desktop-portal-wlr is running"
else
    echo "❌ xdg-desktop-portal-wlr failed to start"
fi

echo ""
echo "🎉 Screen sharing setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Restart Brave browser"
echo "2. Go to a video call website (Google Meet, Zoom, etc.)"
echo "3. Try screen sharing - you should see a selection dialog"
echo ""
echo "💡 If it still doesn't work, try restarting your Sway session"