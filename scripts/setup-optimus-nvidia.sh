#!/bin/bash

echo "Configuring optimus-manager for NVIDIA mode..."

sudo tee /etc/optimus-manager/optimus-manager.conf > /dev/null << 'EOF'
[optimus]
startup_mode=nvidia
switching=none
auto_logout=yes

[nvidia]
modeset=yes
PAT=yes
dynamic_power_management=fine

[intel]
driver=modesetting
DRI=3
EOF

echo "Configuration created. Run 'optimus-manager --switch nvidia' to switch to NVIDIA mode."