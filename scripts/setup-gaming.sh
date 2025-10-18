#!/bin/bash

# Arch Linux Gaming Setup Script for Sway + NVIDIA
# Sets up everything needed to play games (including Rocket League) on Arch with Wayland

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script as root. It will ask for sudo when needed."
        exit 1
    fi
}

enable_multilib() {
    print_step "Enabling multilib repository..."

    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        print_warning "multilib already enabled"
        return
    fi

    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
    sudo pacman -Sy
    print_step "multilib enabled successfully"
}

install_system_dependencies() {
    print_step "Installing system dependencies..."

    local packages=(
        # Vulkan support (essential for gaming)
        vulkan-icd-loader
        lib32-vulkan-icd-loader
        vulkan-tools

        # NVIDIA Vulkan drivers
        nvidia-utils
        lib32-nvidia-utils

        # Mesa and graphics libraries
        lib32-mesa
        mesa-utils

        # Wine and compatibility
        wine-staging
        winetricks

        # XWayland for game compatibility
        xorg-xwayland

        # Additional gaming dependencies
        lib32-libpulse
        lib32-alsa-plugins
        lib32-openal
        gamemode
        lib32-gamemode

        # Font rendering
        lib32-freetype2
        lib32-fontconfig

        # Controller support
        sdl2
        lib32-sdl2
        jstest-gtk
        evtest
    )

    sudo pacman -S --needed --noconfirm "${packages[@]}"
    print_step "System dependencies installed"
}

install_steam() {
    print_step "Installing Steam..."

    if command -v steam &> /dev/null; then
        print_warning "Steam already installed"
    else
        sudo pacman -S --needed --noconfirm steam
        print_step "Steam installed successfully"
    fi

    # Configure Steam library on other disk
    configure_steam_library
}

configure_steam_library() {
    print_step "Configuring Steam library directory..."

    local steam_library_dir="$GAMES_DIR/Steam"

    mkdir -p "$steam_library_dir"

    # Create libraryfolders.vdf if it doesn't exist
    local steam_config_dir="$HOME/.local/share/Steam/config"
    mkdir -p "$steam_config_dir"

    local library_config="$steam_config_dir/libraryfolders.vdf"

    # Only create if Steam hasn't been run yet
    if [[ ! -f "$library_config" ]]; then
        cat > "$library_config" << EOF
"libraryfolders"
{
	"0"
	{
		"path"		"$steam_library_dir"
		"label"		""
		"contentid"		"0"
		"totalsize"		"0"
	}
}
EOF
        print_step "Steam library configured at: $steam_library_dir"
    else
        print_warning "Steam already configured. Add library manually in Steam: Settings → Storage"
        print_warning "Add this path: $steam_library_dir"
    fi
}

install_heroic() {
    print_step "Installing Heroic Games Launcher..."

    if flatpak list | grep -q "com.heroicgameslauncher.hgl"; then
        print_warning "Heroic Games Launcher already installed"
    else
        # Add Flathub if not already added
        if ! flatpak remotes | grep -q "flathub"; then
            print_step "Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi

        flatpak install -y flathub com.heroicgameslauncher.hgl
        print_step "Heroic Games Launcher installed successfully"
    fi

    # Configure Heroic to use custom game directory
    configure_heroic_library
}

configure_heroic_library() {
    print_step "Configuring Heroic Games directory..."

    local heroic_games_dir="$GAMES_DIR/Heroic"
    mkdir -p "$heroic_games_dir"

    # Heroic config location for flatpak
    local heroic_config_dir="$HOME/.var/app/com.heroicgameslauncher.hgl/config/heroic"
    mkdir -p "$heroic_config_dir"

    # Create default config to set install path
    local heroic_config="$heroic_config_dir/config.json"

    if [[ ! -f "$heroic_config" ]]; then
        cat > "$heroic_config" << EOF
{
  "defaultInstallPath": "$heroic_games_dir",
  "defaultWinePrefix": "$heroic_games_dir/Prefixes"
}
EOF
        print_step "Heroic default install path set to: $heroic_games_dir"
    else
        print_warning "Heroic config already exists. Set install path manually in Heroic settings."
        print_warning "Recommended path: $heroic_games_dir"
    fi
}

install_protonup() {
    print_step "Installing ProtonUp-Qt (Proton-GE manager)..."

    if command -v protonup-qt &> /dev/null; then
        print_warning "ProtonUp-Qt already installed"
        return
    fi

    if ! command -v yay &> /dev/null; then
        print_warning "yay not found, skipping ProtonUp-Qt installation"
        print_warning "You can install it manually later with: yay -S protonup-qt"
        return
    fi

    yay -S --needed --noconfirm protonup-qt
    print_step "ProtonUp-Qt installed successfully"
}

configure_environment_variables() {
    print_step "Configuring gaming environment variables..."

    local shell_rc=""
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_rc="$HOME/.bashrc"
    else
        print_warning "No shell RC file found, creating ~/.bashrc"
        shell_rc="$HOME/.bashrc"
        touch "$shell_rc"
    fi

    # Check if gaming variables already exist
    if grep -q "# NVIDIA Wayland gaming" "$shell_rc"; then
        print_warning "Gaming environment variables already configured in $shell_rc"
        return
    fi

    cat >> "$shell_rc" << 'EOF'

# NVIDIA Wayland gaming environment variables
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_RENDERER=vulkan
export WLR_NO_HARDWARE_CURSORS=1

# Gaming-specific optimizations
export PROTON_ENABLE_NVAPI=1
export DXVK_ASYNC=1
export __GL_THREADED_OPTIMIZATIONS=1
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1

# Enable gamemode by default for Steam games
export LD_PRELOAD="${LD_PRELOAD:+$LD_PRELOAD:}libgamemode.so"
EOF

    print_step "Environment variables added to $shell_rc"
    print_warning "You'll need to restart your shell or run: source $shell_rc"
}

configure_sway_gaming() {
    print_step "Configuring Sway for gaming..."

    local sway_config="$HOME/.config/sway/config"

    if [[ ! -f "$sway_config" ]]; then
        print_error "Sway config not found at $sway_config"
        return 1
    fi

    # Check if gaming rules already exist
    if grep -q "# Gaming optimizations" "$sway_config"; then
        print_warning "Sway gaming rules already configured"
        return
    fi

    cat >> "$sway_config" << 'EOF'

# Gaming optimizations
for_window [class="RocketLeague"] inhibit_idle fullscreen
for_window [class="RocketLeague"] fullscreen enable
for_window [title="Rocket League"] inhibit_idle focus

# Steam games
for_window [class="^steam_app_"] inhibit_idle focus
for_window [class="^steam_app_"] fullscreen enable

# Enable adaptive sync for gaming (reduce tearing)
for_window [class="^steam_app_"] exec swaymsg 'output * adaptive_sync on'

# Epic Games via Heroic
for_window [class="heroic"] inhibit_idle focus

# General gaming window rules
for_window [instance="^gamescope"] inhibit_idle focus
for_window [instance="^gamescope"] fullscreen enable
EOF

    print_step "Sway gaming rules added to $sway_config"
    print_warning "Reload Sway config with: swaymsg reload"
}

create_heroic_desktop_fix() {
    print_step "Creating Heroic Games Launcher wrapper for Wayland..."

    local wrapper_script="$HOME/.config/scripts/heroic-wayland.sh"

    mkdir -p "$HOME/.config/scripts"

    cat > "$wrapper_script" << 'EOF'
#!/bin/bash
# Heroic Games Launcher Wayland wrapper with NVIDIA optimizations

export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_RENDERER=vulkan
export PROTON_ENABLE_NVAPI=1
export DXVK_ASYNC=1

flatpak run com.heroicgameslauncher.hgl "$@"
EOF

    chmod +x "$wrapper_script"
    print_step "Heroic wrapper created at $wrapper_script"
}

verify_installation() {
    print_step "Verifying installation..."

    echo ""
    echo -e "${GREEN}=== Verification Results ===${NC}"
    echo ""

    # Check multilib
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "${GREEN}✓${NC} multilib repository: enabled"
    else
        echo -e "${RED}✗${NC} multilib repository: not enabled"
    fi

    # Check Vulkan
    if command -v vulkaninfo &> /dev/null; then
        echo -e "${GREEN}✓${NC} Vulkan tools: installed"
        if vulkaninfo 2>/dev/null | grep -q "NVIDIA"; then
            echo -e "${GREEN}✓${NC} NVIDIA Vulkan driver: working"
        else
            echo -e "${YELLOW}!${NC} NVIDIA Vulkan driver: check needed"
        fi
    else
        echo -e "${RED}✗${NC} Vulkan tools: not found"
    fi

    # Check Steam
    if command -v steam &> /dev/null; then
        echo -e "${GREEN}✓${NC} Steam: installed"
    else
        echo -e "${YELLOW}!${NC} Steam: not installed"
    fi

    # Check Heroic
    if flatpak list | grep -q "com.heroicgameslauncher.hgl"; then
        echo -e "${GREEN}✓${NC} Heroic Games Launcher: installed"
    else
        echo -e "${YELLOW}!${NC} Heroic Games Launcher: not installed"
    fi

    # Check Wine
    if command -v wine &> /dev/null; then
        echo -e "${GREEN}✓${NC} Wine: installed ($(wine --version))"
    else
        echo -e "${RED}✗${NC} Wine: not found"
    fi

    # Check gamemode
    if command -v gamemoded &> /dev/null; then
        echo -e "${GREEN}✓${NC} GameMode: installed"
    else
        echo -e "${YELLOW}!${NC} GameMode: not installed"
    fi

    # Check XWayland
    if command -v Xwayland &> /dev/null; then
        echo -e "${GREEN}✓${NC} XWayland: installed ($(Xwayland -version 2>&1 | head -1))"
    else
        echo -e "${RED}✗${NC} XWayland: not found"
    fi

    echo ""
}

print_next_steps() {
    echo ""
    echo -e "${BLUE}=== Setup Complete! ===${NC}"
    echo ""
    echo -e "${GREEN}Games will be installed to: $GAMES_DIR${NC}"
    echo -e "  - Steam library: $GAMES_DIR/Steam"
    echo -e "  - Heroic games: $GAMES_DIR/Heroic"
    echo -e "  - Available space: $(df -h "$GAMES_DIR" | awk 'NR==2 {print $4}')"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Restart your shell or run:"
    echo -e "   ${YELLOW}source ~/.zshrc${NC}  # or ~/.bashrc"
    echo ""
    echo "2. Reload Sway configuration:"
    echo -e "   ${YELLOW}swaymsg reload${NC}"
    echo ""
    echo "3. For Steam games:"
    echo "   - Launch Steam"
    echo "   - Verify library location in Settings → Storage"
    echo "   - Download Rocket League (if you own it on Steam)"
    echo "   - Right-click Rocket League → Properties → Compatibility"
    echo "   - Enable 'Force compatibility tool' → Select 'Proton Experimental'"
    echo ""
    echo "4. For Epic Games (Heroic):"
    echo "   - Launch: flatpak run com.heroicgameslauncher.hgl"
    echo "   - Or use: ~/.config/scripts/heroic-wayland.sh"
    echo "   - Sign into Epic Games"
    echo "   - Download Rocket League"
    echo "   - Settings → Game Settings → DISABLE 'Use Dedicated Graphics Card'"
    echo "   - Install Proton-GE via Heroic settings (Wine Manager)"
    echo ""
    echo "5. Test Vulkan:"
    echo -e "   ${YELLOW}vkcube${NC}"
    echo ""
    echo "6. Monitor GPU while gaming:"
    echo -e "   ${YELLOW}nvidia-smi -l 1${NC}"
    echo ""
    echo -e "${GREEN}Happy gaming!${NC}"
    echo ""
}

main() {
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Arch Linux Gaming Setup for Sway + NVIDIA           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_root

    # Ask for games installation directory
    echo "Where should games be installed?"
    echo ""
    echo "Available disks:"
    df -h | grep -E '^/dev/' | awk '{printf "  %s on %s (%s available)\n", $1, $6, $4}'
    echo ""
    read -p "Enter games directory [default: $HOME/Games]: " custom_games_dir

    if [[ -z "$custom_games_dir" ]]; then
        export GAMES_DIR="$HOME/Games"
    else
        # Expand ~ if present
        custom_games_dir="${custom_games_dir/#\~/$HOME}"
        export GAMES_DIR="$custom_games_dir"
    fi

    # Create games directory
    mkdir -p "$GAMES_DIR"/{Steam,Heroic,Downloads}

    echo ""
    echo -e "${GREEN}Games will be installed to: $GAMES_DIR${NC}"
    echo -e "Available space: $(df -h "$GAMES_DIR" | awk 'NR==2 {print $4}')"
    echo ""

    # Prompt for what to install
    echo "What would you like to install?"
    echo "1) Full setup (Steam + Heroic + all dependencies)"
    echo "2) Steam only"
    echo "3) Heroic Games Launcher only"
    echo "4) Dependencies only (no game launchers)"
    read -p "Enter choice [1-4]: " choice

    case $choice in
        1)
            enable_multilib
            install_system_dependencies
            install_steam
            install_heroic
            install_protonup
            configure_environment_variables
            configure_sway_gaming
            create_heroic_desktop_fix
            ;;
        2)
            enable_multilib
            install_system_dependencies
            install_steam
            install_protonup
            configure_environment_variables
            configure_sway_gaming
            ;;
        3)
            enable_multilib
            install_system_dependencies
            install_heroic
            configure_environment_variables
            configure_sway_gaming
            create_heroic_desktop_fix
            ;;
        4)
            enable_multilib
            install_system_dependencies
            configure_environment_variables
            configure_sway_gaming
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    verify_installation
    print_next_steps
}

main "$@"
