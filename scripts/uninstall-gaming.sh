#!/bin/bash

# Arch Linux Gaming Uninstall Script
# Removes all gaming setup from setup-gaming.sh

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

remove_gaming_env_vars() {
    print_step "Removing gaming environment variables from shell config..."

    local shell_rc=""
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_rc="$HOME/.bashrc"
    else
        print_warning "No shell RC file found, skipping environment variable removal"
        return
    fi

    # Check if gaming variables exist
    if grep -q "# NVIDIA Wayland gaming" "$shell_rc"; then
        # Remove the gaming environment variables block
        sed -i '/# NVIDIA Wayland gaming environment variables/,/export LD_PRELOAD=.*libgamemode.so/d' "$shell_rc"
        print_step "Gaming environment variables removed from $shell_rc"
    else
        print_warning "Gaming environment variables not found in $shell_rc"
    fi
}

remove_sway_gaming_config() {
    print_step "Removing Sway gaming optimizations..."

    local sway_config="$HOME/.config/sway/config"

    if [[ ! -f "$sway_config" ]]; then
        print_warning "Sway config not found at $sway_config"
        return
    fi

    # Check if gaming rules exist
    if grep -q "# Gaming optimizations" "$sway_config"; then
        # Remove the gaming optimizations block
        sed -i '/# Gaming optimizations/,/^$/d' "$sway_config"
        print_step "Sway gaming rules removed from $sway_config"
    else
        print_warning "Sway gaming rules not found in $sway_config"
    fi
}

remove_heroic() {
    print_step "Removing Heroic Games Launcher..."

    if flatpak list | grep -q "com.heroicgameslauncher.hgl"; then
        flatpak uninstall -y com.heroicgameslauncher.hgl
        print_step "Heroic Games Launcher removed"
    else
        print_warning "Heroic Games Launcher not installed"
    fi
}

remove_steam() {
    print_step "Removing Steam..."

    if command -v steam &> /dev/null; then
        sudo pacman -Rns --noconfirm steam
        print_step "Steam removed"
    else
        print_warning "Steam not installed"
    fi
}

remove_protonup() {
    print_step "Removing ProtonUp-Qt..."

    if command -v protonup-qt &> /dev/null; then
        if command -v yay &> /dev/null; then
            yay -Rns --noconfirm protonup-qt
            print_step "ProtonUp-Qt removed"
        else
            sudo pacman -Rns --noconfirm protonup-qt 2>/dev/null || print_warning "ProtonUp-Qt not found in pacman"
        fi
    else
        print_warning "ProtonUp-Qt not installed"
    fi
}

remove_gaming_packages() {
    print_step "Removing gaming packages..."

    local packages=(
        # Vulkan support
        vulkan-tools

        # Wine and compatibility
        wine-staging
        winetricks

        # Additional gaming dependencies
        gamemode
        lib32-gamemode

        # Controller support
        jstest-gtk
        evtest
    )

    # Only remove packages that are actually installed
    local installed_packages=()
    for pkg in "${packages[@]}"; do
        if pacman -Q "$pkg" &> /dev/null; then
            installed_packages+=("$pkg")
        fi
    done

    if [[ ${#installed_packages[@]} -gt 0 ]]; then
        sudo pacman -Rns --noconfirm "${installed_packages[@]}"
        print_step "Gaming packages removed"
    else
        print_warning "No gaming packages found to remove"
    fi
}

remove_heroic_wrapper() {
    print_step "Removing Heroic wrapper script..."

    local wrapper_script="$HOME/.config/scripts/heroic-wayland.sh"

    if [[ -f "$wrapper_script" ]]; then
        rm "$wrapper_script"
        print_step "Heroic wrapper removed: $wrapper_script"
    else
        print_warning "Heroic wrapper not found"
    fi
}

show_remaining_data() {
    print_step "Checking for remaining game data..."

    echo ""
    echo -e "${YELLOW}=== Remaining Game Data ===${NC}"
    echo ""

    # Check for Steam data
    if [[ -d "$HOME/.local/share/Steam" ]]; then
        local steam_size=$(du -sh "$HOME/.local/share/Steam" 2>/dev/null | cut -f1)
        echo -e "${YELLOW}!${NC} Steam data directory: $HOME/.local/share/Steam ($steam_size)"
        echo "  To remove: rm -rf ~/.local/share/Steam"
    fi

    # Check for Heroic data
    if [[ -d "$HOME/.var/app/com.heroicgameslauncher.hgl" ]]; then
        local heroic_size=$(du -sh "$HOME/.var/app/com.heroicgameslauncher.hgl" 2>/dev/null | cut -f1)
        echo -e "${YELLOW}!${NC} Heroic data directory: $HOME/.var/app/com.heroicgameslauncher.hgl ($heroic_size)"
        echo "  To remove: rm -rf ~/.var/app/com.heroicgameslauncher.hgl"
    fi

    # Check for Wine prefixes
    if [[ -d "$HOME/.wine" ]]; then
        local wine_size=$(du -sh "$HOME/.wine" 2>/dev/null | cut -f1)
        echo -e "${YELLOW}!${NC} Wine prefix: $HOME/.wine ($wine_size)"
        echo "  To remove: rm -rf ~/.wine"
    fi

    # Check for game directories
    if [[ -d "$HOME/Games" ]]; then
        local games_size=$(du -sh "$HOME/Games" 2>/dev/null | cut -f1)
        echo -e "${YELLOW}!${NC} Games directory: $HOME/Games ($games_size)"
        echo "  To remove: rm -rf ~/Games"
    fi

    # Check for other potential game locations
    for dir in /media/*/Games /mnt/*/Games; do
        if [[ -d "$dir" ]]; then
            local dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo -e "${YELLOW}!${NC} Games directory: $dir ($dir_size)"
            echo "  To remove manually if needed"
        fi
    done

    echo ""
}

main() {
    echo -e "${RED}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║     Arch Linux Gaming Uninstall Script                   ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_root

    # Prompt for what to remove
    echo "What would you like to remove?"
    echo "1) Everything (complete uninstall)"
    echo "2) Game launchers only (keep system dependencies)"
    echo "3) Custom selection"
    echo "4) Just remove configs (keep all software)"
    read -p "Enter choice [1-4]: " choice

    case $choice in
        1)
            remove_gaming_env_vars
            remove_sway_gaming_config
            remove_heroic
            remove_steam
            remove_protonup
            remove_gaming_packages
            remove_heroic_wrapper
            ;;
        2)
            remove_gaming_env_vars
            remove_sway_gaming_config
            remove_heroic
            remove_steam
            remove_protonup
            remove_heroic_wrapper
            ;;
        3)
            echo ""
            echo "Select components to remove (y/n):"

            read -p "Remove gaming environment variables? [y/n]: " remove_env
            [[ "$remove_env" == "y" ]] && remove_gaming_env_vars

            read -p "Remove Sway gaming config? [y/n]: " remove_sway
            [[ "$remove_sway" == "y" ]] && remove_sway_gaming_config

            read -p "Remove Heroic Games Launcher? [y/n]: " remove_heroic_choice
            [[ "$remove_heroic_choice" == "y" ]] && remove_heroic

            read -p "Remove Steam? [y/n]: " remove_steam_choice
            [[ "$remove_steam_choice" == "y" ]] && remove_steam

            read -p "Remove ProtonUp-Qt? [y/n]: " remove_protonup_choice
            [[ "$remove_protonup_choice" == "y" ]] && remove_protonup

            read -p "Remove gaming packages? [y/n]: " remove_packages
            [[ "$remove_packages" == "y" ]] && remove_gaming_packages

            read -p "Remove Heroic wrapper script? [y/n]: " remove_wrapper
            [[ "$remove_wrapper" == "y" ]] && remove_heroic_wrapper
            ;;
        4)
            remove_gaming_env_vars
            remove_sway_gaming_config
            remove_heroic_wrapper
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac

    show_remaining_data

    echo ""
    echo -e "${GREEN}=== Uninstall Complete! ===${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Restart your shell or run:"
    echo -e "   ${YELLOW}source ~/.zshrc${NC}  # or ~/.bashrc"
    echo ""
    echo "2. Reload Sway configuration:"
    echo -e "   ${YELLOW}swaymsg reload${NC}"
    echo ""
    echo "3. (Optional) Remove game data directories shown above"
    echo ""
    echo "4. (Optional) Disable multilib if not needed:"
    echo "   Edit /etc/pacman.conf and comment out [multilib] section"
    echo ""
}

main "$@"
