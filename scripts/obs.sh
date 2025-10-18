#!/bin/bash

# OBS Studio launcher for Sway/Wayland with proper environment
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

exec obs
