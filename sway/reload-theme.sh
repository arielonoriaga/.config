#!/bin/bash
# Theme reload script for Catppuccin Mocha setup

echo "🎨 Reloading Catppuccin Mocha theme..."

# Apply GTK themes
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Blue-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-blue-cursors'
gsettings set org.gnome.desktop.interface font-name 'JetBrainsMonoNL Nerd Font 10'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Reload Sway configuration
swaymsg reload

# Restart Waybar to apply new styling
pkill waybar
waybar &

echo "✅ Theme reloaded! Your system now uses Catppuccin Mocha colors."
echo ""
echo "🔧 To complete setup, install these packages:"
echo "   yay -S catppuccin-gtk-theme-mocha"
echo "   yay -S catppuccin-cursors-mocha" 
echo "   yay -S papirus-icon-theme"
echo ""
echo "📱 Configured applications:"
echo "   • Sway window manager (blue borders, dark theme)"
echo "   • Waybar (already themed)"
echo "   • Alacritty terminal"
echo "   • Foot terminal" 
echo "   • Thunar file manager"
echo "   • Wofi launcher"
echo "   • GTK applications"