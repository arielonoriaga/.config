#!/bin/bash

# Set random wallpaper from ~/backgrounds using feh
WALLPAPER_DIR="$HOME/backgrounds"

# Check if directory exists and has images
if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \) | shuf -n 1)

if [ -n "$WALLPAPER" ]; then
    # Kill any existing swaybg processes
    pkill swaybg 2>/dev/null
    
    # Try swaybg first (recommended), fallback to swaymsg
    if command -v swaybg >/dev/null 2>&1; then
        swaybg -i "$WALLPAPER" -m fill &
        echo "Wallpaper set with swaybg: $WALLPAPER"
    else
        swaymsg output "*" bg "$WALLPAPER" fill
        echo "Wallpaper set with swaymsg: $WALLPAPER"
    fi
else
    echo "No valid image files found in $WALLPAPER_DIR"
fi