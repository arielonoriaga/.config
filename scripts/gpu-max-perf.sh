#!/bin/bash
# Pin the 3080 to max-performance clocks instead of letting PowerMizer idle it
# at ~285MHz. Trades idle power/heat for lower latency jitter.
# Applies on next reboot. Undo: delete the block and rebuild nothing (modprobe
# options are read at module load).
set -euo pipefail
grep -q PowerMizer /etc/modprobe.d/nvidia.conf && { echo "already applied"; exit 0; }
sudo cp /etc/modprobe.d/nvidia.conf /etc/modprobe.d/nvidia.conf.bak
sudo tee -a /etc/modprobe.d/nvidia.conf >/dev/null <<'CONF'

# Max-performance clocks. Desktop on mains: latency > idle wattage.
options nvidia NVreg_PowerMizerEnable=0
options nvidia NVreg_PowerMizerLevel=0x1
options nvidia NVreg_PowerMizerLevelAC=0x1
CONF
echo "Added. Takes effect after reboot."
