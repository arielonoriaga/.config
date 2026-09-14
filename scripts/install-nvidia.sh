#!/bin/bash
# NVIDIA setup for this desktop: RTX 3080 (GA102, Ampere), stock `linux` kernel,
# UEFI + systemd-boot, single GPU (no Optimus).
#
# Run:  ~/.config/scripts/install-nvidia.sh
set -euo pipefail
[ "$EUID" -eq 0 ] && { echo "Run as your user, not root — it calls sudo itself."; exit 1; }

echo "==> 1/6  Enabling multilib (32-bit, for Steam/Proton/Wine)"
if grep -q '^\[multilib\]' /etc/pacman.conf; then
  echo "    already enabled"
else
  sudo cp -n /etc/pacman.conf /etc/pacman.conf.bak
  # Uncomment ONLY [multilib] + its Include. The $ anchor keeps
  # [multilib-testing] commented out.
  sudo sed -i '/^#\[multilib\]$/{s/^#//;n;s/^#//}' /etc/pacman.conf
  grep -A1 '^\[multilib\]' /etc/pacman.conf
fi
sudo pacman -Sy

echo "==> 2/6  Installing driver"
# `nvidia`/`nvidia-dkms` (proprietary) no longer exist in Arch; nvidia-open is the
# only option, and is what NVIDIA recommends for Turing and newer anyway.
# nvidia-open is prebuilt against `linux`, so no DKMS and no linux-headers needed.
# lib32-nvidia-utils version must match nvidia-utils; installing together guarantees it.
# nvidia-utils ships the Vulkan ICD itself; the loaders are separate packages
# and Proton/Wine need the 32-bit one.
sudo pacman -S --needed nvidia-open nvidia-utils lib32-nvidia-utils \
                        vulkan-icd-loader lib32-vulkan-icd-loader \
                        egl-wayland libva-nvidia-driver

echo "==> 3/6  mkinitcpio: load nvidia early, stop nouveau being pulled in"
sudo cp -n /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
sudo sed -i \
  -e 's|^MODULES=(.*)|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)|' \
  -e 's|^\(HOOKS=(.*\) kms \(.*\)|\1 \2|' \
  /etc/mkinitcpio.conf
grep -E '^MODULES|^HOOKS' /etc/mkinitcpio.conf

echo "==> 4/6  Driver options"
sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<'EOF'
# Wayland needs modeset; fbdev gives a working console.
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_UsePageAttributeTable=1

# Keep VRAM across suspend. TemporaryFilePath MUST be real disk: /tmp is tmpfs
# (7.7G) on this box and the card has 12G of VRAM, so suspend would fill RAM.
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp

# Dropped from the laptop config, deliberately — see notes:
#   NVreg_DynamicPowerManagement  (Optimus runtime PM, desktop has no use for it)
#   NVreg_PowerMizer*             (pins clocks at max: more heat/idle draw)
#   NVreg_EnablePCIeGen3          (no-op on a Gen4 card)
#   NVreg_EnableMSI               (already the default)
EOF
cat /etc/modprobe.d/nvidia.conf

echo "==> 5/6  Rebuilding initramfs"
sudo mkinitcpio -P

echo "==> 6/6  Done. Reboot, then verify with:"
echo "    nvidia-smi"
echo "    hyprctl systeminfo | grep -i gpu"
echo "    pacman -Q lib32-nvidia-utils lib32-vulkan-icd-loader"
echo "    vulkaninfo --summary | head       # needs vulkan-tools"
