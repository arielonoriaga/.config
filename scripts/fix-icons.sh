#!/bin/bash

# Fix missing icons and emojis script
echo "🔧 Fixing missing icons and emojis..."

# Install required fonts and icon themes
echo "Installing required packages..."
sudo pacman -S --needed --noconfirm \
    hicolor-icon-theme \
    noto-fonts-emoji \
    ttf-nerd-fonts-symbols-mono \
    ttf-font-awesome

# Update icon caches (requires sudo for system themes)
echo "Updating icon caches..."
sudo gtk-update-icon-cache -f -t /usr/share/icons/Papirus-Dark 2>/dev/null
sudo gtk-update-icon-cache -f -t /usr/share/icons/Papirus 2>/dev/null
sudo gtk-update-icon-cache -f -t /usr/share/icons/Adwaita 2>/dev/null
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null

# Update font cache
echo "Updating font cache..."
fc-cache -fv

# Refresh GTK settings
echo "Refreshing GTK settings..."
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Create fontconfig for emoji support if it doesn't exist
if [ ! -f ~/.config/fontconfig/fonts.conf ]; then
    echo "Creating fontconfig for emoji support..."
    mkdir -p ~/.config/fontconfig
    cat > ~/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>JetBrainsMonoNL Nerd Font</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMonoNL Nerd Font</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF
fi

# For Wayland/Sway - restart waybar if running
if pgrep waybar >/dev/null; then
    echo "Restarting waybar..."
    pkill waybar
    waybar &
fi

echo "✅ Icons and emoji fix complete!"
echo "You may need to restart applications or run: sway reload"
echo "Test emoji: 😀 🎉 ❤️"