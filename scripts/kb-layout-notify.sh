#!/bin/sh
# Notifies via notify-send whenever sway's active keyboard layout changes.
swaymsg -t subscribe -m '["input"]' | \
    jq --unbuffered -r 'select(.change == "xkb_layout") | .input.xkb_active_layout_name' | \
    while read -r layout; do
        notify-send -t 1200 -h string:x-canonical-private-synchronous:kb-layout "Keyboard layout" "$layout"
    done
