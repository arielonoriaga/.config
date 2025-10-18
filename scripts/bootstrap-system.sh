#!/bin/bash

# Arch Linux Post-Installation Bootstrap Script
# Automated setup for development environment with Sway + Wayland
# Excludes gaming setup - for gaming run setup-gaming.sh separately

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${MAGENTA}$1${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do not run this script as root. It will ask for sudo when needed."
        exit 1
    fi
}

check_internet() {
    print_step "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        print_error "No internet connection. Please connect and try again."
        exit 1
    fi
    print_success "Internet connection detected"
}

update_system() {
    print_header "Updating System"
    print_step "Running full system update..."
    sudo pacman -Syu --noconfirm
    print_success "System updated"
}

install_base_packages() {
    print_header "Installing Base Packages"

    local packages=(
        git
        base-devel
        zsh
        wget
        curl
        unzip
        zip
        man-db
        man-pages
        htop
    )

    print_step "Installing base packages..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    print_success "Base packages installed"
}

install_yay() {
    print_header "Installing Yay (AUR Helper)"

    if command -v yay &> /dev/null; then
        print_warning "Yay already installed"
        return
    fi

    print_step "Cloning yay repository..."
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay

    print_step "Building and installing yay..."
    makepkg -si --noconfirm

    cd ~
    print_success "Yay installed successfully"
}

install_sway_wayland() {
    print_header "Installing Sway + Wayland Environment"

    local packages=(
        # Core Sway
        sway
        swayidle
        swaylock
        swaybg

        # Wayland essentials
        xorg-xwayland
        wl-clipboard

        # Bars and menus
        waybar
        wofi

        # Notifications
        mako

        # Screenshot tools
        grim
        slurp

        # Terminal emulators
        alacritty
        foot

        # Audio
        pulseaudio
        pavucontrol

        # Brightness
        brightnessctl

        # File manager
        thunar
        thunar-volman
        gvfs

        # XDG portals for screen sharing
        xdg-desktop-portal
        xdg-desktop-portal-wlr
    )

    print_step "Installing Sway and Wayland components..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    print_success "Sway + Wayland environment installed"
}

detect_and_install_gpu_drivers() {
    print_header "GPU Driver Detection and Setup"

    # Detect GPU type
    local has_nvidia=$(lspci | grep -i nvidia)
    local has_amd=$(lspci | grep -i "vga.*amd\|vga.*radeon")
    local has_intel=$(lspci | grep -i "vga.*intel")

    echo "Detected GPUs:"
    if [ -n "$has_nvidia" ]; then
        echo "  - NVIDIA GPU detected"
    fi
    if [ -n "$has_amd" ]; then
        echo "  - AMD GPU detected"
    fi
    if [ -n "$has_intel" ]; then
        echo "  - Intel GPU detected"
    fi
    echo ""

    # Install NVIDIA drivers
    if [ -n "$has_nvidia" ]; then
        print_step "Installing NVIDIA drivers..."

        local nvidia_packages=(
            nvidia
            nvidia-utils
            nvidia-settings
            lib32-nvidia-utils
            egl-wayland
        )

        sudo pacman -S --needed --noconfirm "${nvidia_packages[@]}"

        # Enable nvidia-drm modeset
        if [ -x "$HOME/.config/scripts/enable-nvidia-modeset.sh" ]; then
            print_step "Enabling NVIDIA DRM modeset..."
            sudo "$HOME/.config/scripts/enable-nvidia-modeset.sh"
        fi

        print_success "NVIDIA drivers installed"
    fi

    # Install AMD drivers
    if [ -n "$has_amd" ]; then
        print_step "Installing AMD drivers..."

        local amd_packages=(
            mesa
            lib32-mesa
            vulkan-radeon
            lib32-vulkan-radeon
        )

        sudo pacman -S --needed --noconfirm "${amd_packages[@]}"
        print_success "AMD drivers installed"
    fi

    # Install Intel drivers
    if [ -n "$has_intel" ]; then
        print_step "Installing Intel drivers..."

        local intel_packages=(
            mesa
            lib32-mesa
            vulkan-intel
            lib32-vulkan-intel
            intel-media-driver
            libva-intel-driver
        )

        sudo pacman -S --needed --noconfirm "${intel_packages[@]}"
        print_success "Intel drivers installed"
    fi

    # If no GPU detected
    if [ -z "$has_nvidia" ] && [ -z "$has_amd" ] && [ -z "$has_intel" ]; then
        print_warning "No dedicated GPU detected, installing basic Mesa drivers..."
        sudo pacman -S --needed --noconfirm mesa lib32-mesa
    fi
}

install_display_manager() {
    print_header "Installing Display Manager (SDDM)"

    print_step "Installing SDDM..."
    sudo pacman -S --needed --noconfirm sddm

    print_step "Enabling SDDM service..."
    sudo systemctl enable sddm

    # Fix NVIDIA with SDDM if script exists and NVIDIA GPU detected
    if lspci | grep -i nvidia &> /dev/null; then
        if [ -x "$HOME/.config/scripts/fix-sddm-nvidia.sh" ]; then
            print_step "Applying NVIDIA fixes for SDDM..."
            sudo "$HOME/.config/scripts/fix-sddm-nvidia.sh"
        fi
    fi

    print_success "SDDM installed and enabled"
}

setup_zsh() {
    print_header "Setting Up Zsh Shell"

    # Set zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_step "Setting Zsh as default shell..."
        chsh -s $(which zsh)
        print_success "Zsh set as default shell (takes effect after logout)"
    else
        print_warning "Zsh already set as default shell"
    fi

    # Copy zshrc to home directory
    if [ -f "$HOME/.config/.zshrc" ]; then
        print_step "Copying .zshrc to home directory..."
        cp "$HOME/.config/.zshrc" "$HOME/.zshrc"
        print_success "Zsh configuration copied"
    fi

    # Copy p10k config
    if [ -f "$HOME/.config/.p10k.zsh" ]; then
        print_step "Copying Powerlevel10k configuration..."
        cp "$HOME/.config/.p10k.zsh" "$HOME/.p10k.zsh"
        print_success "Powerlevel10k configuration copied"
    fi

    # Install p10k fonts
    print_step "Installing Powerlevel10k fonts..."
    yay -S --needed --noconfirm ttf-meslo-nerd-font-powerlevel10k || print_warning "Could not install p10k fonts via yay"
}

setup_terminal_tools() {
    print_header "Setting Up Terminal Tools"

    local packages=(
        tmux
        neovim
        htop
        btop
        fzf
        ripgrep
        fd
        eza
        bat
    )

    print_step "Installing terminal utilities..."
    sudo pacman -S --needed --noconfirm "${packages[@]}"

    # Copy tmux config
    if [ -f "$HOME/.config/.tmux.conf" ]; then
        print_step "Copying tmux configuration..."
        cp "$HOME/.config/.tmux.conf" "$HOME/.tmux.conf"
        print_success "Tmux configuration copied"
    fi

    # Copy vim config
    if [ -f "$HOME/.config/.vimrc" ]; then
        print_step "Copying vim configuration..."
        cp "$HOME/.config/.vimrc" "$HOME/.vimrc"
        print_success "Vim configuration copied"
    fi

    print_success "Terminal tools installed"
}

install_development_tools() {
    print_header "Installing Development Environment"

    # Install Go
    print_step "Installing Go..."
    sudo pacman -S --needed --noconfirm go
    print_success "Go installed"

    # Install Docker
    print_step "Installing Docker..."
    sudo pacman -S --needed --noconfirm docker docker-compose
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    print_success "Docker installed (you'll need to logout/login for docker group)"

    # Install lazydocker
    print_step "Installing lazydocker..."
    yay -S --needed --noconfirm lazydocker || print_warning "Could not install lazydocker"

    # Install lazygit
    print_step "Installing lazygit..."
    sudo pacman -S --needed --noconfirm lazygit
    print_success "Lazygit installed"

    # Install NVM
    if [ ! -d "$HOME/.nvm" ]; then
        print_step "Installing NVM (Node Version Manager)..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        print_success "NVM installed"
    else
        print_warning "NVM already installed"
    fi

    # Install pnpm
    if ! command -v pnpm &> /dev/null; then
        print_step "Installing pnpm..."
        curl -fsSL https://get.pnpm.io/install.sh | sh -
        print_success "pnpm installed"
    else
        print_warning "pnpm already installed"
    fi

    # Install bun
    if ! command -v bun &> /dev/null; then
        print_step "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
        print_success "bun installed"
    else
        print_warning "bun already installed"
    fi
}

install_applications() {
    print_header "Installing Applications"

    # Install Brave browser
    print_step "Installing Brave browser..."
    yay -S --needed --noconfirm brave-bin || print_warning "Could not install Brave browser"

    # Make Brave Wayland wrapper executable
    if [ -f "$HOME/.config/scripts/brave-wayland.sh" ]; then
        chmod +x "$HOME/.config/scripts/brave-wayland.sh"
    fi

    # Install Insomnia (API client)
    print_step "Installing Insomnia..."
    yay -S --needed --noconfirm insomnia-bin || print_warning "Could not install Insomnia"

    print_success "Applications installed"
}

setup_icons_fonts() {
    print_header "Setting Up Icons & Fonts"

    print_step "Installing icon themes and fonts..."
    sudo pacman -S --needed --noconfirm \
        papirus-icon-theme \
        noto-fonts \
        noto-fonts-emoji \
        ttf-dejavu \
        ttf-liberation \
        otf-font-awesome

    # Run icon fix if script exists
    if [ -x "$HOME/.config/scripts/fix-icons.sh" ]; then
        print_step "Running icon cache fix..."
        "$HOME/.config/scripts/fix-icons.sh"
    fi

    print_success "Icons and fonts installed"
}

setup_screen_sharing() {
    print_header "Setting Up Screen Sharing for Wayland"

    if [ -x "$HOME/.config/scripts/fix-screenshare.sh" ]; then
        print_step "Configuring screen sharing..."
        "$HOME/.config/scripts/fix-screenshare.sh"
        print_success "Screen sharing configured"
    else
        print_warning "Screen sharing script not found, skipping"
    fi
}

make_scripts_executable() {
    print_header "Making Scripts Executable"

    if [ -d "$HOME/.config/scripts" ]; then
        print_step "Setting executable permissions on all scripts..."
        chmod +x "$HOME/.config/scripts/"*
        print_success "Scripts are now executable"
    fi
}

setup_flatpak() {
    print_header "Setting Up Flatpak (Optional)"

    read -p "Do you want to install Flatpak? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Installing Flatpak..."
        sudo pacman -S --needed --noconfirm flatpak

        print_step "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        print_success "Flatpak installed and configured"
    else
        print_warning "Skipping Flatpak installation"
    fi
}

verify_installation() {
    print_header "Verifying Installation"

    echo ""
    echo -e "${GREEN}=== Verification Results ===${NC}"
    echo ""

    # Check Sway
    if command -v sway &> /dev/null; then
        print_success "Sway: installed ($(sway --version))"
    else
        print_error "Sway: not found"
    fi

    # Check Waybar
    if command -v waybar &> /dev/null; then
        print_success "Waybar: installed"
    else
        print_warning "Waybar: not found"
    fi

    # Check Zsh
    if command -v zsh &> /dev/null; then
        print_success "Zsh: installed ($(zsh --version))"
    else
        print_error "Zsh: not found"
    fi

    # Check Yay
    if command -v yay &> /dev/null; then
        print_success "Yay: installed ($(yay --version | head -1))"
    else
        print_warning "Yay: not found"
    fi

    # Check Docker
    if command -v docker &> /dev/null; then
        print_success "Docker: installed ($(docker --version))"
    else
        print_warning "Docker: not found"
    fi

    # Check NVIDIA
    if command -v nvidia-smi &> /dev/null; then
        print_success "NVIDIA drivers: installed"
        if nvidia-smi &> /dev/null; then
            print_success "NVIDIA GPU: working"
        else
            print_warning "NVIDIA GPU: check needed (may require reboot)"
        fi
    fi

    # Check Neovim
    if command -v nvim &> /dev/null; then
        print_success "Neovim: installed ($(nvim --version | head -1))"
    else
        print_warning "Neovim: not found"
    fi

    # Check lazygit
    if command -v lazygit &> /dev/null; then
        print_success "Lazygit: installed"
    else
        print_warning "Lazygit: not found"
    fi

    # Check NVM
    if [ -d "$HOME/.nvm" ]; then
        print_success "NVM: installed"
    else
        print_warning "NVM: not found"
    fi

    # Check pnpm
    if command -v pnpm &> /dev/null; then
        print_success "pnpm: installed"
    else
        print_warning "pnpm: not found"
    fi

    # Check bun
    if command -v bun &> /dev/null; then
        print_success "bun: installed"
    else
        print_warning "bun: not found"
    fi

    echo ""
}

print_next_steps() {
    print_header "Setup Complete!"

    echo ""
    echo -e "${GREEN}Your system has been configured successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo ""
    echo "1. ${YELLOW}Reboot your system${NC}"
    echo "   sudo reboot"
    echo ""
    echo "2. ${YELLOW}After reboot, login via SDDM${NC}"
    echo "   Select 'Sway' as your session"
    echo ""
    echo "3. ${YELLOW}First time in Sway:${NC}"
    echo "   - Zinit will auto-install when you open terminal (zsh)"
    echo "   - Powerlevel10k configuration wizard may run"
    echo "   - Your scripts are in ~/.config/scripts/ (already in PATH)"
    echo ""
    echo "4. ${YELLOW}Optional setup:${NC}"
    echo "   - Gaming: ~/.config/scripts/setup-gaming.sh"
    echo "   - Xbox Controller: ~/.config/scripts/setup-xbox-controller.sh"
    echo "   - Screen Recording: ~/.config/scripts/setup-screenrecord.sh"
    echo ""
    echo "5. ${YELLOW}Key bindings (Mod4 = Super/Windows key):${NC}"
    echo "   - Mod4 + Return: Terminal"
    echo "   - Mod4 + d: App launcher"
    echo "   - Mod4 + Shift + q: Kill window"
    echo "   - Print: Screenshot area"
    echo "   - Shift + Print: Screenshot fullscreen"
    echo ""
    echo "6. ${YELLOW}Test GPU acceleration (after reboot):${NC}"
    echo "   ~/.config/scripts/test-gpu-acceleration.sh"
    echo ""
    echo -e "${GREEN}Happy coding!${NC}"
    echo ""
}

show_summary() {
    print_header "Installation Summary"

    echo "The following has been installed and configured:"
    echo ""
    echo "✓ Base system packages and build tools"
    echo "✓ Yay (AUR helper)"
    echo "✓ Sway + Wayland environment"
    echo "✓ NVIDIA drivers (if detected)"
    echo "✓ SDDM display manager"
    echo "✓ Zsh with Zinit and Powerlevel10k"
    echo "✓ Terminal tools (tmux, neovim, etc.)"
    echo "✓ Development environment (Go, Docker, NVM, pnpm, bun)"
    echo "✓ Applications (Brave, Insomnia)"
    echo "✓ Icons and fonts"
    echo "✓ Screen sharing configuration"
    echo "✓ All dotfiles and scripts"
    echo ""
}

main() {
    clear
    print_header "Arch Linux Bootstrap - Development Setup"

    echo -e "${YELLOW}This script will set up your complete development environment${NC}"
    echo -e "${YELLOW}It will NOT install gaming components (run setup-gaming.sh separately)${NC}"
    echo ""
    echo "This will:"
    echo "  - Update your system"
    echo "  - Install Sway + Wayland"
    echo "  - Install NVIDIA drivers (if GPU detected)"
    echo "  - Setup Zsh with plugins"
    echo "  - Install development tools (Docker, Node, Go, etc.)"
    echo "  - Install applications (Brave, Insomnia, etc.)"
    echo "  - Configure all dotfiles"
    echo ""
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi

    echo ""

    check_root
    check_internet

    update_system
    install_base_packages
    install_yay
    install_sway_wayland
    detect_and_install_gpu_drivers
    install_display_manager
    setup_zsh
    setup_terminal_tools
    install_development_tools
    install_applications
    setup_icons_fonts
    setup_screen_sharing
    make_scripts_executable
    setup_flatpak

    verify_installation
    show_summary
    print_next_steps

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Bootstrap completed successfully!              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main "$@"
