#!/bin/bash

# SwayFX Installation and Configuration Script
# Adds 5px rounded corners to Sway windows

set -e

echo "🚀 Installing SwayFX with rounded corners..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}❌ This script is designed for Arch Linux${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing SwayFX from AUR...${NC}"

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}🔧 Installing yay AUR helper...${NC}"
    sudo pacman -S --needed git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Install SwayFX
echo -e "${BLUE}🎨 Installing SwayFX...${NC}"
yay -S --noconfirm swayfx

# Backup current Sway config
echo -e "${YELLOW}💾 Backing up current Sway config...${NC}"
cp ~/.config/sway/config ~/.config/sway/config.backup.$(date +%Y%m%d_%H%M%S)

# Add SwayFX configuration
echo -e "${BLUE}⚙️  Configuring rounded corners...${NC}"

# Check if rounded corners are already configured
if ! grep -q "corner_radius" ~/.config/sway/config; then
    cat >> ~/.config/sway/config << 'EOF'

# SwayFX - Rounded corners and visual effects
corner_radius 5
shadows enable
shadow_blur_radius 10
shadow_color #00000080
layer_effects "waybar" blur enable; shadows enable

# Optional blur effects (uncomment if desired)
# blur enable
# blur_xray enable
# blur_passes 2
# blur_radius 5

EOF
    echo -e "${GREEN}✅ Added SwayFX configuration to Sway config${NC}"
else
    echo -e "${YELLOW}⚠️  SwayFX configuration already exists in Sway config${NC}"
fi

# Update desktop entry to use SwayFX
echo -e "${BLUE}🖥️  Updating desktop entry for SwayFX...${NC}"
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/swayfx.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=SwayFX
Comment=An i3-compatible Wayland compositor with effects
Exec=sway
TryExec=sway
Type=Application
EOF

# Create SwayFX startup script
echo -e "${BLUE}📝 Creating SwayFX startup script...${NC}"
cat > ~/.config/scripts/start-swayfx.sh << 'EOF'
#!/bin/bash

# Start SwayFX with optimizations
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=vulkan
export WLR_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# Start SwayFX
exec sway "$@"
EOF

chmod +x ~/.config/scripts/start-swayfx.sh

echo -e "${GREEN}🎉 SwayFX installation complete!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "   1. ${YELLOW}Log out of your current session${NC}"
echo -e "   2. ${YELLOW}Select 'SwayFX' from your login manager${NC}"
echo -e "   3. ${YELLOW}Or run: ~/.config/scripts/start-swayfx.sh${NC}"
echo ""
echo -e "${BLUE}🔧 Configuration added:${NC}"
echo -e "   • ${GREEN}5px rounded corners${NC}"
echo -e "   • ${GREEN}Window shadows${NC}"
echo -e "   • ${GREEN}Waybar blur effects${NC}"
echo ""
echo -e "${YELLOW}💡 To reload current session: swaymsg reload${NC}"
echo -e "${YELLOW}📁 Config backup saved to: ~/.config/sway/config.backup.*${NC}"