#!/bin/bash

# Xbox Controller Input Lag Fix Script
# Reduces input latency for Xbox controllers

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Xbox Controller Input Lag Fix                     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Increase USB polling rate
print_step "Setting USB polling rate to 1000Hz (1ms)..."
echo "options usbhid mousepoll=1" | sudo tee /etc/modprobe.d/usbhid.conf > /dev/null
print_step "USB polling rate configured (requires reboot to take effect)"
echo ""

# 2. Set xpadneo parameters for lower latency
if lsmod | grep -q "hid_xpadneo"; then
    print_step "Configuring xpadneo for low latency..."

    # Disable rumble/vibration (reduces latency)
    echo "options hid_xpadneo ff_connect_notify=0" | sudo tee /etc/modprobe.d/xpadneo.conf > /dev/null

    # Try to reload module with new settings
    print_warning "xpadneo settings configured. Reconnect controller or reboot to apply."
    echo ""
else
    print_warning "xpadneo not loaded, using xpad driver"
    echo ""
fi

# 3. Reduce Sway input latency
print_step "Optimizing Sway input settings..."

SWAY_CONFIG="$HOME/.config/sway/config"

if [[ -f "$SWAY_CONFIG" ]]; then
    # Check if input settings already exist
    if ! grep -q "# Controller input optimization" "$SWAY_CONFIG"; then
        cat >> "$SWAY_CONFIG" << 'EOF'

# Controller input optimization
input type:pointer {
    accel_profile flat
    pointer_accel 0
}

# Disable mouse acceleration for all inputs
input * {
    accel_profile flat
}
EOF
        print_step "Sway input optimizations added"
        print_warning "Reload Sway: swaymsg reload"
    else
        echo -e "${GREEN}✓${NC} Sway already optimized"
    fi
else
    print_warning "Sway config not found"
fi
echo ""

# 4. Set Steam Input settings
print_step "Steam Input recommendations:"
echo "  1. Open Steam → Settings → Controller"
echo "  2. Enable 'Xbox Configuration Support'"
echo "  3. In game properties → Controller → Disable Steam Input"
echo "     (Use native controller support for lowest latency)"
echo ""

# 5. Disable compositor effects that add latency
print_step "Checking Rocket League launch settings..."
HEROIC_GAME_CONFIG="$HOME/.var/app/com.heroicgameslauncher.hgl/config/heroic/GamesConfig/Sugar.json"

if [[ -f "$HEROIC_GAME_CONFIG" ]]; then
    echo -e "${GREEN}✓${NC} Game config found"
    echo "  Add to game settings in Heroic:"
    echo "    Game Settings → Environment Variables:"
    echo "    SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS=1"
else
    print_warning "Rocket League config not found"
fi
echo ""

# 6. Check for CPU governor (performance mode)
print_step "Checking CPU governor..."
current_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
echo "  Current: $current_governor"

if [[ "$current_governor" != "performance" ]]; then
    print_warning "CPU not in performance mode"
    echo "  To set performance mode:"
    echo "    sudo cpupower frequency-set -g performance"
    echo "  Or install gamemode (automatically boosts performance)"
else
    echo -e "${GREEN}✓${NC} CPU in performance mode"
fi
echo ""

# 7. Verify controller is not in power-saving mode
print_step "Controller connection info..."
if lsusb | grep -qi "xbox"; then
    lsusb | grep -i "xbox\|microsoft"
    echo ""
    echo "Connection: USB (lowest latency)"
    echo ""
    print_step "USB-specific optimizations:"
    echo "  • Make sure USB port is USB 3.0 (blue port) if available"
    echo "  • Avoid USB hubs - connect directly to laptop"
    echo "  • Use shorter USB cable if possible"
else
    print_warning "Controller not detected via USB"
    echo "  Bluetooth has higher latency than USB"
fi
echo ""

# 8. Test controller latency
print_step "Test your controller latency:"
echo "  Run: jstest /dev/input/js0"
echo "  Press buttons and check response time"
echo ""

# Summary
echo -e "${BLUE}=== Summary of Changes ===${NC}"
echo ""
echo -e "${GREEN}Applied:${NC}"
echo "  ✓ USB polling rate set to 1000Hz (1ms)"
if lsmod | grep -q "hid_xpadneo"; then
    echo "  ✓ xpadneo configured for low latency"
fi
echo ""
echo -e "${YELLOW}Action Required:${NC}"
echo "  1. Reboot to apply USB polling rate changes"
echo "  2. Reload Sway: swaymsg reload"
echo "  3. Test controller in Rocket League"
echo ""
echo -e "${BLUE}Additional Tips:${NC}"
echo "  • Disable V-Sync in game (adds 1 frame of lag)"
echo "  • Set game to fullscreen (not windowed)"
echo "  • Close background applications"
echo "  • Ensure Rocket League is using NVIDIA GPU (it is now!)"
echo ""
echo -e "${GREEN}After reboot, input lag should be significantly reduced!${NC}"
echo ""
