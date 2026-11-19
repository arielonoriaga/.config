#!/bin/bash
AC=/sys/class/power_supply/ADP1/online

ac_status() { cat "$AC" 2>/dev/null || echo "0"; }

start_swayidle() {
    pkill -x swayidle 2>/dev/null
    sleep 0.3
    if [ "$(ac_status)" = "1" ]; then
        # ponytail: on AC, no idle handling at all -- no screen-off, no lock on suspend
        :
    else
        swayidle -w \
            timeout 300 'swaylock -f' \
            timeout 600 'swaymsg "output * power off"' \
            resume 'swaymsg "output * power on"' \
            before-sleep 'swaylock -f' &
    fi
}

LAST=$(ac_status)
start_swayidle

while sleep 10; do
    CURRENT=$(ac_status)
    if [ "$CURRENT" != "$LAST" ]; then
        LAST=$CURRENT
        start_swayidle
    fi
done
