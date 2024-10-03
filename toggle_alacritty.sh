#!/bin/bash

# Define the Alacritty window class
WIN_CLASS="Alacritty"

# Get the Alacritty window ID
ALACRITTY_ID=$(xdotool search --class $WIN_CLASS | head -n 1)

if [ -z "$ALACRITTY_ID" ]; then
    # If no Alacritty window is found, launch Alacritty
    alacritty &
    exit 0
fi

# Get the currently focused window ID
FOCUSED_WINDOW=$(xdotool getwindowfocus)

if [ "$FOCUSED_WINDOW" = "$ALACRITTY_ID" ]; then
    # If Alacritty is focused, minimize it
    xdotool windowminimize $ALACRITTY_ID
else
    # If Alacritty is running but not focused, bring it to the front
    wmctrl -i -a $ALACRITTY_ID
fi
