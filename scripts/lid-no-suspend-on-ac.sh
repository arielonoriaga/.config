#!/bin/bash
# Run with sudo. Stops lid-close from suspending while on AC power.
set -e
install -Dm644 /dev/stdin /etc/systemd/logind.conf.d/lid.conf <<'CONF'
[Login]
HandleLidSwitchExternalPower=ignore
CONF
systemctl restart systemd-logind
echo "done. verify:"
busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
    org.freedesktop.login1.Manager HandleLidSwitchExternalPower
