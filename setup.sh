#!/bin/bash

# Modern .config Setup Script
# This script sets up a complete development environment based on the .config directory

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    log_success "System updated"
}

# Install essential packages
install_essential_packages() {
    log_info "Installing essential packages..."
    
    local packages=(
        "curl"
        "wget"
        "git"
        "zsh"
        "gcc"
        "g++"
        "make"
        "build-essential"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "xclip"
        "ripgrep"
        "jq"
        "unzip"
        "htop"
        "tree"
        "fd-find"
        "bat"
        "exa"
    )
    
    sudo apt-get install -y "${packages[@]}"
    log_success "Essential packages installed"
}

# Install Node.js LTS
install_nodejs() {
    log_info "Installing Node.js LTS..."
    
    if command -v node &> /dev/null; then
        log_warning "Node.js already installed: $(node --version)"
        return
    fi
    
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    log_success "Node.js installed: $(node --version)"
}

# Install Docker
install_docker() {
    log_info "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        log_warning "Docker already installed: $(docker --version)"
        return
    fi
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    log_success "Docker installed. Please log out and back in for group changes to take effect."
}

# Install Neovim
install_neovim() {
    log_info "Installing Neovim..."
    
    if command -v nvim &> /dev/null; then
        log_warning "Neovim already installed: $(nvim --version | head -1)"
        return
    fi
    
    # Create temporary directory
    mkdir -p ~/temp-setup
    cd ~/temp-setup
    
    # Download latest Neovim AppImage
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    
    # Move to system location
    sudo mv nvim.appimage /usr/local/bin/nvim
    
    # Cleanup
    cd ~
    rm -rf ~/temp-setup
    
    log_success "Neovim installed: $(nvim --version | head -1)"
}

# Install LazyGit
install_lazygit() {
    log_info "Installing LazyGit..."
    
    if command -v lazygit &> /dev/null; then
        log_warning "LazyGit already installed: $(lazygit --version)"
        return
    fi
    
    # Add LazyGit PPA
    sudo add-apt-repository ppa:lazygit-team/release
    sudo apt-get update
    sudo apt-get install -y lazygit
    
    log_success "LazyGit installed: $(lazygit --version)"
}

# Install LazyDocker
install_lazydocker() {
    log_info "Installing LazyDocker..."
    
    if command -v lazydocker &> /dev/null; then
        log_warning "LazyDocker already installed: $(lazydocker --version)"
        return
    fi
    
    # Create temporary directory
    mkdir -p ~/temp-setup
    cd ~/temp-setup
    
    # Get latest version
    local version=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    
    # Download and extract
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${version}_Linux_x86_64.tar.gz"
    tar xf lazydocker.tar.gz
    
    # Move to system location
    sudo mv lazydocker /usr/local/bin/
    
    # Cleanup
    cd ~
    rm -rf ~/temp-setup
    
    log_success "LazyDocker installed: $(lazydocker --version)"
}

# Install FZF
install_fzf() {
    log_info "Installing FZF..."
    
    if command -v fzf &> /dev/null; then
        log_warning "FZF already installed"
        return
    fi
    
    # Clone and install FZF
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
    
    log_success "FZF installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    
    if [[ -d ~/.oh-my-zsh ]]; then
        log_warning "Oh My Zsh already installed"
        return
    fi
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    log_success "Oh My Zsh installed"
}

# Install Zsh plugins
install_zsh_plugins() {
    log_info "Installing Zsh plugins..."
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Powerlevel10k theme
    if [[ ! -d "$custom_dir/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
        log_success "Powerlevel10k installed"
    fi
}

# Create symbolic links
create_symlinks() {
    log_info "Creating symbolic links..."
    
    local config_dir="$HOME/.config"
    
    # Backup existing files
    backup_file() {
        local file=$1
        if [[ -f "$file" && ! -L "$file" ]]; then
            mv "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
            log_warning "Backed up existing $file"
        fi
    }
    
    # Create symlinks for dotfiles
    local files=(
        ".zshrc"
        ".vimrc"
        ".p10k.zsh"
        ".fzf.zsh"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$config_dir/$file" ]]; then
            backup_file "$HOME/$file"
            ln -sf "$config_dir/$file" "$HOME/$file"
            log_success "Linked $file"
        fi
    done
    
    # System-wide configs (requires sudo)
    if [[ -f "$config_dir/journald.conf" ]]; then
        sudo ln -sf "$config_dir/journald.conf" /etc/systemd/journald.conf
        log_success "Linked journald.conf"
    fi
}

# Change default shell to Zsh
change_shell() {
    log_info "Changing default shell to Zsh..."
    
    if [[ "$SHELL" == */zsh ]]; then
        log_warning "Zsh is already the default shell"
        return
    fi
    
    chsh -s $(which zsh)
    log_success "Default shell changed to Zsh (restart terminal to take effect)"
}

# Main installation function
main() {
    log_info "Starting .config setup..."
    
    # Check prerequisites
    check_root
    
    # System setup
    update_system
    install_essential_packages
    
    # Development tools
    install_nodejs
    install_yarn
    install_docker
    install_docker_compose
    
    # Terminal tools
    install_neovim
    install_lazygit
    install_lazydocker
    install_fzf
    
    # Shell setup
    install_oh_my_zsh
    install_zsh_plugins
    
    # Configuration
    create_symlinks
    change_shell
    
    log_success "Setup complete!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_info "If you installed Docker, please log out and back in for group permissions"
}

# Parse command line arguments
case "${1:-all}" in
    "essential")
        update_system
        install_essential_packages
        ;;
    "dev")
        install_nodejs
        install_yarn
        install_docker
        install_docker_compose
        ;;
    "tools")
        install_neovim
        install_lazygit
        install_lazydocker
        install_fzf
        ;;
    "shell")
        install_oh_my_zsh
        install_zsh_plugins
        change_shell
        ;;
    "links")
        create_symlinks
        ;;
    "all")
        main
        ;;
    *)
        echo "Usage: $0 [essential|dev|tools|shell|links|all]"
        echo "  essential - Install essential packages"
        echo "  dev       - Install development tools (Node.js, Docker, etc.)"
        echo "  tools     - Install terminal tools (Neovim, LazyGit, etc.)"
        echo "  shell     - Setup Zsh and plugins"
        echo "  links     - Create symbolic links"
        echo "  all       - Run complete setup (default)"
        exit 1
        ;;
esac
