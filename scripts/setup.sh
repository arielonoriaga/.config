#!/bin/bash

# Arch Linux + Sway + NVIDIA Setup Script
# Auto-configures dotfiles and optimizations for future OS installations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
LOCAL_SHARE_DIR="$HOME/.local/share"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

check_dependencies() {
    log_info "Checking system dependencies..."
    
    local missing_deps=()
    local deps=("sway" "waybar" "wofi" "brave" "alacritty" "nvim")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_warning "Missing dependencies: ${missing_deps[*]}"
        log_info "Install with: sudo pacman -S ${missing_deps[*]}"
    else
        log_success "All dependencies found"
    fi
}

setup_nvidia_wayland() {
    log_info "Setting up NVIDIA Wayland configuration..."
    
    # Copy NVIDIA kernel module configuration
    if [ -f "$SCRIPT_DIR/../nvidia-wayland.conf" ]; then
        sudo cp "$SCRIPT_DIR/../nvidia-wayland.conf" /etc/modprobe.d/nvidia.conf
        log_success "NVIDIA kernel module configuration applied"
        log_warning "Reboot required for NVIDIA changes to take effect"
    else
        log_warning "nvidia-wayland.conf not found"
    fi
}

setup_sway_config() {
    log_info "Setting up Sway configuration..."
    
    # Ensure sway config directory exists
    mkdir -p "$CONFIG_DIR/sway"
    
    # Update script paths in sway config if needed
    if [ -f "$CONFIG_DIR/sway/config" ]; then
        sed -i "s|~/.config/.*\.sh|~/scripts/|g" "$CONFIG_DIR/sway/config"
        log_success "Sway configuration updated"
    fi
}

setup_brave_optimization() {
    log_info "Setting up Brave browser optimizations..."
    
    # Ensure applications directory exists
    mkdir -p "$LOCAL_SHARE_DIR/applications"
    
    # Update Brave desktop launcher
    if [ -f "$LOCAL_SHARE_DIR/applications/brave-browser.desktop" ]; then
        sed -i "s|/home/[^/]*/\.config/|$SCRIPT_DIR/|g" "$LOCAL_SHARE_DIR/applications/brave-browser.desktop"
        log_success "Brave desktop launcher updated"
    fi
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh
    log_success "Scripts made executable"
}

setup_gitignore() {
    log_info "Updating .gitignore for unnecessary files..."
    
    if [ -f "$CONFIG_DIR/.gitignore" ]; then
        # Add common entries if not present
        local gitignore_entries=(
            "configstore/"
            "pavucontrol.ini"
            "htop/htoprc"
            "*.log"
            "*.cache"
            "*.tmp"
            "BraveSoftware/"
            "go/telemetry/"
            "pulse/"
        )
        
        for entry in "${gitignore_entries[@]}"; do
            if ! grep -q "^$entry" "$CONFIG_DIR/.gitignore"; then
                echo "$entry" >> "$CONFIG_DIR/.gitignore"
            fi
        done
        
        log_success ".gitignore updated"
    fi
}

create_symlinks() {
    log_info "Creating symlinks for configuration files..."
    
    # Link scripts directory to common locations
    ln -sf "$SCRIPT_DIR" "$HOME/bin" 2>/dev/null || true
    
    log_success "Symlinks created"
}

run_optimization_scripts() {
    log_info "Running optimization scripts..."
    
    # Run available optimization scripts
    local opt_scripts=(
        "fix-wayland-flickering.sh"
        "optimize-brave-performance.sh"
        "low-latency-wayland.sh"
    )
    
    for script in "${opt_scripts[@]}"; do
        if [ -f "$SCRIPT_DIR/$script" ]; then
            log_info "Running $script..."
            bash "$SCRIPT_DIR/$script" || log_warning "Failed to run $script"
        fi
    done
}

main() {
    log_info "Starting Arch Linux + Sway + NVIDIA setup..."
    echo
    
    check_dependencies
    echo
    
    setup_nvidia_wayland
    echo
    
    setup_sway_config
    echo
    
    setup_brave_optimization
    echo
    
    setup_gitignore
    echo
    
    create_symlinks
    echo
    
    run_optimization_scripts
    echo
    
    log_success "Setup completed!"
    echo
    log_info "Next steps:"
    echo "  1. Reboot to apply NVIDIA kernel module changes"
    echo "  2. Run 'swaymsg reload' to restart Sway compositor"
    echo "  3. Test Brave browser scrolling performance"
    echo
    log_info "Scripts location: $SCRIPT_DIR"
    log_info "Configuration location: $CONFIG_DIR"
}

# Handle command line arguments
case "${1:-}" in
    --nvidia-only)
        setup_nvidia_wayland
        ;;
    --browser-only)
        setup_brave_optimization
        ;;
    --check-deps)
        check_dependencies
        ;;
    --help|-h)
        echo "Usage: $0 [option]"
        echo "Options:"
        echo "  --nvidia-only   Setup NVIDIA configuration only"
        echo "  --browser-only  Setup browser optimizations only"
        echo "  --check-deps    Check system dependencies only"
        echo "  --help, -h      Show this help message"
        echo "  (no option)     Run full setup"
        ;;
    *)
        main
        ;;
esac