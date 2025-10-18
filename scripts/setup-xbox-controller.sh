#!/bin/bash

# Xbox Controller Setup Script for Arch Linux
# Installs drivers, tools, and configures Xbox controllers for gaming

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

install_basic_controller_support() {
    print_step "Installing basic controller support packages..."

    local packages=(
        # SDL2 for controller support (required by Steam/Proton)
        sdl2
        lib32-sdl2

        # Testing and configuration tools
        evtest
        joyutils
    )

    sudo pacman -S --needed --noconfirm "${packages[@]}"
    print_step "Basic controller support installed"
}

check_xpad_driver() {
    print_step "Checking built-in xpad driver..."

    if lsmod | grep -q "xpad"; then
        echo -e "${GREEN}✓ xpad driver is loaded${NC}"
    else
        echo -e "${YELLOW}! xpad driver not currently loaded${NC}"
        echo "  (It will load automatically when you connect an Xbox controller)"
    fi
}

install_xpadneo() {
    print_step "Installing xpadneo (advanced Xbox wireless driver)..."

    echo ""
    echo "xpadneo provides enhanced features for Xbox controllers:"
    echo "  • Better Bluetooth support"
    echo "  • Rumble/vibration support"
    echo "  • Battery level reporting"
    echo "  • Improved wireless performance"
    echo ""
    echo "Note: Only needed for Bluetooth Xbox controllers"
    echo ""

    read -p "Install xpadneo? [y/N]: " install_choice

    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        # Check if yay is available
        if ! command -v yay &> /dev/null; then
            print_error "yay not found. Install yay first or install xpadneo manually."
            print_warning "Manual installation: yay -S xpadneo-dkms"
            return
        fi

        # Install linux-headers first (required for DKMS)
        print_step "Installing linux-headers (required for xpadneo)..."
        sudo pacman -S --needed --noconfirm linux-headers

        # Install xpadneo
        yay -S --needed --noconfirm xpadneo-dkms

        # Load the module
        print_step "Loading xpadneo module..."
        sudo modprobe hid-xpadneo

        print_step "xpadneo installed and loaded successfully"

        # Create modprobe config to load on boot
        echo "hid-xpadneo" | sudo tee /etc/modules-load.d/xpadneo.conf > /dev/null
        print_step "xpadneo configured to load on boot"
    else
        print_warning "Skipping xpadneo installation"
        echo "USB Xbox controllers will work fine with the built-in xpad driver"
    fi
}

configure_udev_rules() {
    print_step "Configuring udev rules for Xbox controllers..."

    # Check if user is in input group
    if ! groups | grep -q "input"; then
        print_step "Adding user to 'input' group for controller access..."
        sudo usermod -a -G input "$USER"
        print_warning "You'll need to log out and log back in for group changes to take effect"
    else
        echo -e "${GREEN}✓ User already in 'input' group${NC}"
    fi

    # Create udev rule for Xbox controllers
    local udev_rule="/etc/udev/rules.d/99-xbox-controller.rules"

    if [[ ! -f "$udev_rule" ]]; then
        print_step "Creating udev rules for Xbox controllers..."

        sudo tee "$udev_rule" > /dev/null << 'EOF'
# Xbox 360 Controller
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"

# Xbox 360 Wireless Receiver
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0666"

# Xbox One Controller (USB)
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02dd", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02e3", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0666"

# Xbox One Elite Controller
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02e0", MODE="0666"

# Xbox Series X|S Controller
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b13", MODE="0666"

# Xbox controllers via Bluetooth
KERNEL=="js[0-9]*", SUBSYSTEM=="input", ATTRS{name}=="Xbox*", MODE="0666"
EOF

        sudo udevadm control --reload-rules
        sudo udevadm trigger

        print_step "udev rules created and loaded"
    else
        echo -e "${GREEN}✓ udev rules already exist${NC}"
    fi
}

configure_steam_input() {
    print_step "Configuring Steam Input for Xbox controllers..."

    # Create Steam launch options file
    local steam_config_dir="$HOME/.local/share/Steam"

    if [[ -d "$steam_config_dir" ]]; then
        echo -e "${GREEN}✓ Steam directory found${NC}"
        echo ""
        echo "To enable full Xbox controller support in Steam:"
        echo "1. Open Steam"
        echo "2. Go to Settings → Controller → General Controller Settings"
        echo "3. Enable 'Xbox Configuration Support'"
        echo "4. Test your controller with the 'Calibrate' option"
    else
        print_warning "Steam not installed or hasn't been run yet"
        echo "Run Steam first, then configure controller support in Settings → Controller"
    fi
}

detect_connected_controllers() {
    print_step "Detecting connected Xbox controllers..."
    echo ""

    # Check USB
    local usb_controllers=$(lsusb | grep -i "xbox\|microsoft.*controller" || true)
    if [[ -n "$usb_controllers" ]]; then
        echo -e "${GREEN}USB Xbox controllers detected:${NC}"
        echo "$usb_controllers" | while read line; do
            echo "  • $line"
        done
    else
        echo -e "${YELLOW}No USB Xbox controllers detected${NC}"
    fi

    echo ""

    # Check input devices
    if ls /dev/input/js* &>/dev/null; then
        echo -e "${GREEN}Joystick devices found:${NC}"
        for js in /dev/input/js*; do
            echo "  • $js"
        done
    else
        echo -e "${YELLOW}No joystick devices found${NC}"
        echo "  (Connect a controller and it should appear automatically)"
    fi

    echo ""
}

test_controller() {
    print_step "Testing Xbox controller..."
    echo ""

    if ! ls /dev/input/js* &>/dev/null; then
        print_warning "No controller detected. Please connect a controller first."
        return
    fi

    echo "Choose a test method:"
    echo "1) jstest - Simple button/axis testing"
    echo "2) evtest - Detailed event monitoring (requires sudo)"
    echo "3) Skip testing"
    echo ""
    read -p "Enter choice [1-3]: " test_choice

    case $test_choice in
        1)
            print_step "Starting jstest on /dev/input/js0..."
            echo "Press buttons and move sticks. Press Ctrl+C to exit."
            echo ""
            sleep 2
            jstest /dev/input/js0
            ;;
        2)
            print_step "Starting evtest..."
            echo "Select your Xbox controller from the list."
            echo ""
            sudo evtest
            ;;
        3)
            echo "Skipping controller test"
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

print_troubleshooting() {
    echo ""
    echo -e "${BLUE}=== Troubleshooting ===${NC}"
    echo ""
    echo "If your controller doesn't work:"
    echo ""
    echo "1. Check if it's detected:"
    echo "   lsusb | grep -i xbox"
    echo "   ls /dev/input/js*"
    echo ""
    echo "2. Check kernel messages:"
    echo "   dmesg | grep -i xbox"
    echo "   dmesg | tail -20"
    echo ""
    echo "3. Verify driver is loaded:"
    echo "   lsmod | grep xpad"
    echo ""
    echo "4. For Bluetooth controllers:"
    echo "   • Pair via bluetoothctl or your desktop's Bluetooth settings"
    echo "   • Install xpadneo for better support: yay -S xpadneo-dkms"
    echo ""
    echo "5. Test the controller:"
    echo "   jstest /dev/input/js0"
    echo ""
    echo "6. For Steam games:"
    echo "   • Enable Xbox Configuration Support in Steam settings"
    echo "   • Check Controller settings in Big Picture Mode"
    echo ""
    echo "7. Common issues:"
    echo "   • USB cable faulty: Try a different cable"
    echo "   • USB port issue: Try a different port"
    echo "   • Permissions: Make sure you're in the 'input' group"
    echo ""
}

print_next_steps() {
    echo ""
    echo -e "${BLUE}=== Setup Complete! ===${NC}"
    echo ""
    echo "Xbox controller support has been configured!"
    echo ""
    echo -e "${GREEN}What's installed:${NC}"
    echo "  • SDL2 controller libraries"
    echo "  • jstest/evtest testing tools"
    echo "  • udev rules for Xbox controllers"
    echo "  • Built-in xpad driver (loaded automatically)"
    if lsmod | grep -q "hid_xpadneo"; then
        echo "  • xpadneo advanced wireless driver"
    fi
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo ""
    echo "1. Connect your Xbox controller (USB or Bluetooth)"
    echo ""
    echo "2. Test it works:"
    echo "   ~/.config/scripts/test-controller.sh"
    echo "   OR"
    echo "   jstest /dev/input/js0"
    echo ""
    echo "3. For Steam games:"
    echo "   • Open Steam → Settings → Controller"
    echo "   • Enable 'Xbox Configuration Support'"
    echo ""
    echo "4. For Rocket League:"
    echo "   • Just launch the game, controller will work automatically"
    echo "   • Configure controls in-game if needed"
    echo ""
    if ! groups | grep -q "input"; then
        echo -e "${YELLOW}IMPORTANT:${NC} Log out and back in for group changes to take effect"
        echo ""
    fi
    echo -e "${GREEN}Happy gaming!${NC}"
    echo ""
}

verify_installation() {
    print_step "Verifying installation..."
    echo ""

    # Check SDL2
    if pacman -Q sdl2 &>/dev/null; then
        echo -e "${GREEN}✓ SDL2 installed${NC}"
    else
        echo -e "${RED}✗ SDL2 not installed${NC}"
    fi

    if pacman -Q lib32-sdl2 &>/dev/null; then
        echo -e "${GREEN}✓ lib32-SDL2 installed${NC}"
    else
        echo -e "${RED}✗ lib32-SDL2 not installed${NC}"
    fi

    # Check jstest
    if command -v jstest &>/dev/null; then
        echo -e "${GREEN}✓ jstest installed${NC}"
    else
        echo -e "${RED}✗ jstest not installed${NC}"
    fi

    # Check evtest
    if command -v evtest &>/dev/null; then
        echo -e "${GREEN}✓ evtest installed${NC}"
    else
        echo -e "${RED}✗ evtest not installed${NC}"
    fi

    # Check xpad driver
    if modinfo xpad &>/dev/null; then
        echo -e "${GREEN}✓ xpad driver available${NC}"
    else
        echo -e "${YELLOW}! xpad driver not found${NC}"
    fi

    # Check xpadneo if installed
    if lsmod | grep -q "hid_xpadneo"; then
        echo -e "${GREEN}✓ xpadneo driver loaded${NC}"
    elif modinfo hid-xpadneo &>/dev/null 2>&1; then
        echo -e "${YELLOW}! xpadneo installed but not loaded${NC}"
    fi

    # Check user groups
    if groups | grep -q "input"; then
        echo -e "${GREEN}✓ User in 'input' group${NC}"
    else
        echo -e "${YELLOW}! User NOT in 'input' group (will be added)${NC}"
    fi

    echo ""
}

main() {
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Xbox Controller Setup for Arch Linux              ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_root

    echo "This script will install and configure Xbox controller support."
    echo ""
    echo "What will be installed:"
    echo "  • SDL2 libraries (for gaming compatibility)"
    echo "  • Testing tools (jstest, evtest)"
    echo "  • udev rules for proper permissions"
    echo "  • Optional: xpadneo driver (for Bluetooth controllers)"
    echo ""
    read -p "Continue? [Y/n]: " confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi

    echo ""

    # Installation steps
    install_basic_controller_support
    check_xpad_driver
    configure_udev_rules

    echo ""
    install_xpadneo

    echo ""
    configure_steam_input

    echo ""
    verify_installation

    echo ""
    detect_connected_controllers

    echo ""
    test_controller

    print_troubleshooting
    print_next_steps
}

main "$@"
