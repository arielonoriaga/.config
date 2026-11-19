#!/bin/bash
choice=$(printf '󰌾  Lock\n󰍃  Log out\n󰜉  Reboot\n󰐥  Shut down\n' | fuzzel --dmenu --prompt '' --lines 4 --width 16)
case "$choice" in
  *Lock) hyprlock ;;
  *"Log out") hyprctl dispatch 'hl.dsp.exit()' ;;
  *Reboot) systemctl reboot ;;
  *"Shut down") systemctl poweroff ;;
esac
