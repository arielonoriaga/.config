#!/bin/sh
# tmux status battery segment: color by level, bolt when charging
B=/sys/class/power_supply/BAT1
read -r c < "$B/capacity" || exit 0
read -r s < "$B/status"
if [ "$c" -lt 20 ]; then style='#[bg=#bf616a,fg=#eceff4]'
elif [ "$c" -lt 50 ]; then style='#[bg=#ebcb8b,fg=#2e3440]'
else style='#[bg=#a3be8c,fg=#2e3440]'
fi
[ "$s" = Discharging ] && bolt='' || bolt=' ⚡'
printf '%s %s%%%s ' "$style" "$c" "$bolt"
