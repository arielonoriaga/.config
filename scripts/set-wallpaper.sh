#!/bin/bash
# Random wallpaper from ~/backgrounds, via hyprpaper (Hyprland-native).
# Replaces the old sway/set_wallpaper.sh, which used swaybg.
set -u
WALLPAPER_DIR="$HOME/Pictures/Backgrounds"

[ -d "$WALLPAPER_DIR" ] || { echo "No wallpaper dir: $WALLPAPER_DIR"; exit 1; }
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) \
  | shuf -n 1)
[ -n "$WALLPAPER" ] || { echo "No images in $WALLPAPER_DIR"; exit 1; }

pgrep -x hyprpaper >/dev/null 2>&1 || { hyprpaper >/dev/null 2>&1 & sleep 1; }
for monitor in $(hyprctl monitors -j | python3 -I -c 'import json, sys; print(" ".join(m["name"] for m in json.load(sys.stdin)))'); do
  hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER" >/dev/null
done
echo "Wallpaper: $WALLPAPER"
"$HOME/.config/scripts/rgb-from-wallpaper.py" "$WALLPAPER" &
