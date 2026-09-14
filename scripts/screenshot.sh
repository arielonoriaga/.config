#!/bin/bash

# Screenshot script for Sway using grim and slurp
# Usage: screenshot.sh [fullscreen|area|window]

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="screenshot_${DATE}.png"
FILEPATH="${SCREENSHOT_DIR}/${FILENAME}"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

case "${1:-area}" in
    "fullscreen"|"full")
        # Take fullscreen screenshot
        grim "$FILEPATH"
        ;;
    "area"|"region")
        # Take area screenshot with selection
        grim -g "$(slurp)" "$FILEPATH"
        ;;
    "window")
        # Take window screenshot
        # Window geometry source depends on the compositor.
        if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
            GEOM=$(hyprctl clients -j | jq -r '.[] | select(.mapped and .hidden == false) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        else
            GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
        fi
        grim -g "$(echo "$GEOM" | slurp)" "$FILEPATH"
        ;;
    *)
        echo "Usage: $0 [fullscreen|area|window]"
        echo "Default: area"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo "Screenshot saved to: $FILEPATH"
    # Copy to clipboard
    wl-copy < "$FILEPATH"
    # Send notification
    notify-send "Screenshot" "Saved to $FILENAME" -i "$FILEPATH"
else
    echo "Screenshot failed"
    exit 1
fi