#!/bin/bash

# Xbox Controller Testing Script
# Tests Xbox controller connectivity and functionality

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=== Xbox Controller Test ===${NC}"
    echo ""
}

check_controller_connected() {
    echo -e "${BLUE}Checking for connected controllers...${NC}"
    echo ""

    # Check for input devices
    if ls /dev/input/js* &>/dev/null; then
        echo -e "${GREEN}✓ Joystick devices found:${NC}"
        ls -l /dev/input/js* | awk '{print "  " $NF}'
    else
        echo -e "${YELLOW}! No joystick devices found${NC}"
    fi

    echo ""

    # Check for event devices
    if ls /dev/input/event* &>/dev/null; then
        echo -e "${GREEN}✓ Event devices:${NC}"
        for device in /dev/input/event*; do
            if [[ -r "$device" ]]; then
                name=$(cat "/sys/class/input/$(basename $device)/device/name" 2>/dev/null || echo "Unknown")
                if [[ "$name" =~ "Xbox" ]] || [[ "$name" =~ "Controller" ]] || [[ "$name" =~ "Gamepad" ]]; then
                    echo -e "  ${GREEN}$device: $name${NC}"
                fi
            fi
        done
    fi

    echo ""
}

check_kernel_module() {
    echo -e "${BLUE}Checking kernel modules...${NC}"
    echo ""

    if lsmod | grep -q "xpad"; then
        echo -e "${GREEN}✓ xpad module loaded (built-in Xbox controller driver)${NC}"
    else
        echo -e "${YELLOW}! xpad module not loaded${NC}"
    fi

    if lsmod | grep -q "hid_xpadneo"; then
        echo -e "${GREEN}✓ xpadneo module loaded (advanced Xbox wireless driver)${NC}"
    else
        echo -e "${YELLOW}! xpadneo module not loaded (optional, for advanced features)${NC}"
    fi

    echo ""
}

check_sdl2() {
    echo -e "${BLUE}Checking SDL2 support...${NC}"
    echo ""

    if command -v sdl2-jstest &>/dev/null; then
        echo -e "${GREEN}✓ SDL2 joystick test available${NC}"
        echo "  Run: sdl2-jstest --list"
    else
        if pacman -Q sdl2 &>/dev/null; then
            echo -e "${GREEN}✓ SDL2 installed${NC}"
        else
            echo -e "${RED}✗ SDL2 not installed${NC}"
            echo "  Install with: sudo pacman -S sdl2 lib32-sdl2"
        fi
    fi

    echo ""
}

test_controller() {
    echo -e "${BLUE}Controller Test Options:${NC}"
    echo ""
    echo "1. Test with jstest (press buttons to see output)"
    echo "2. Test with evtest (detailed event monitoring)"
    echo "3. List SDL2 controllers"
    echo "4. Show all input devices"
    echo "5. Exit"
    echo ""
    read -p "Choose an option [1-5]: " choice

    case $choice in
        1)
            if command -v jstest &>/dev/null; then
                if ls /dev/input/js* &>/dev/null; then
                    echo ""
                    echo -e "${GREEN}Starting jstest...${NC}"
                    echo "Press Ctrl+C to exit"
                    echo ""
                    jstest /dev/input/js0
                else
                    echo -e "${RED}No joystick device found${NC}"
                fi
            else
                echo -e "${RED}jstest not found. Install: sudo pacman -S joyutils${NC}"
            fi
            ;;
        2)
            if command -v evtest &>/dev/null; then
                echo ""
                echo -e "${GREEN}Available input devices:${NC}"
                echo ""
                sudo evtest
            else
                echo -e "${RED}evtest not found. Install: sudo pacman -S evtest${NC}"
            fi
            ;;
        3)
            if command -v sdl2-jstest &>/dev/null; then
                echo ""
                sdl2-jstest --list
            else
                echo -e "${YELLOW}sdl2-jstest not found${NC}"
                echo "Install SDL2 tools: yay -S sdl2-jstest-git"
            fi
            ;;
        4)
            echo ""
            echo -e "${GREEN}Input devices:${NC}"
            ls -l /dev/input/
            ;;
        5)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

print_tips() {
    echo ""
    echo -e "${BLUE}=== Xbox Controller Tips ===${NC}"
    echo ""
    echo "Connection methods:"
    echo "  • USB: Plug in and it should work immediately"
    echo "  • Wireless (Xbox Wireless Adapter): Usually works with xpad driver"
    echo "  • Bluetooth: Pair normally, may need xpadneo for advanced features"
    echo ""
    echo "If controller doesn't work:"
    echo "  1. Check USB cable/connection"
    echo "  2. Try a different USB port"
    echo "  3. Check dmesg for errors: dmesg | grep -i xbox"
    echo "  4. For Bluetooth controllers, install xpadneo:"
    echo "     yay -S xpadneo-dkms"
    echo ""
    echo "For Steam games:"
    echo "  • Steam has built-in controller configuration"
    echo "  • Enable Steam Input in controller settings"
    echo "  • Most games auto-detect Xbox controllers"
    echo ""
    echo "For Rocket League specifically:"
    echo "  • Xbox controllers work out-of-the-box"
    echo "  • No special configuration needed"
    echo "  • Both wired and wireless work"
    echo ""
}

main() {
    print_header
    check_controller_connected
    check_kernel_module
    check_sdl2

    if ls /dev/input/js* &>/dev/null; then
        echo -e "${GREEN}Controller detected! Ready to test.${NC}"
        echo ""
        test_controller
    else
        echo -e "${YELLOW}No controller detected.${NC}"
        echo ""
        echo "Please connect your Xbox controller and run this script again."
        echo ""
        echo "Checking USB devices for Xbox controllers:"
        lsusb | grep -i "xbox\|microsoft.*controller" || echo "  No Xbox controllers found via USB"
    fi

    print_tips
}

main "$@"
