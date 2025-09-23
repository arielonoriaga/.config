#!/bin/bash

echo "Fixing SDDM NVIDIA display configuration..."

# Create SDDM configuration for NVIDIA
sudo tee /etc/sddm.conf.d/10-nvidia.conf << 'EOF'
[General]
DisplayServer=x11

[X11]
ServerPath=/usr/bin/Xorg
ServerArguments=-nolisten tcp -background none -keeptty -noreset -verbose 3
EOF

# Update the existing optimus manager SDDM config
sudo tee /etc/sddm.conf.d/20-optimus-manager.conf << 'EOF'
[X11]
DisplayCommand=/sbin/prime-offload
DisplayStopCommand=/sbin/prime-switch
ServerArguments=-nolisten tcp -background none -keeptty -noreset -verbose 3 -dpi 96
EOF

echo "SDDM configuration updated. Restarting SDDM..."
sudo systemctl restart sddm

echo "Done! SDDM should now work properly with NVIDIA."