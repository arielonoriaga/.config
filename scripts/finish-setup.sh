#!/bin/bash
# Installs the packages this config needs. Run once: ~/.config/scripts/finish-setup.sh
set -e
sudo pacman -S --needed base-devel unzip fd nodejs npm \
    wofi mako brightnessctl swaybg wf-recorder fzf

# rebuild the nvim bits that needed a compiler
nvim --headless "+Lazy! build telescope-fzf-native.nvim" +qa
nvim --headless "+TSUpdateSync" +qa
echo "done"
