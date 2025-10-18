#!/bin/bash

# GPU Acceleration Test Script
# Tests GPU acceleration for gaming and apps

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== GPU Acceleration Test ===${NC}"
echo ""

# Test 1: NVIDIA driver
echo -e "${BLUE}1. NVIDIA Driver Status:${NC}"
if nvidia-smi &>/dev/null; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | \
        awk -F', ' '{printf "   GPU: %s\n   Driver: %s\n   VRAM: %s\n", $1, $2, $3}'
    echo -e "${GREEN}✓ NVIDIA driver working${NC}"
else
    echo -e "${RED}✗ NVIDIA driver not working${NC}"
fi
echo ""

# Test 2: OpenGL
echo -e "${BLUE}2. OpenGL Acceleration:${NC}"
if command -v glxinfo &>/dev/null; then
    renderer=$(glxinfo | grep "OpenGL renderer" | cut -d':' -f2 | xargs)
    version=$(glxinfo | grep "OpenGL version" | cut -d':' -f2 | xargs)
    echo "   Renderer: $renderer"
    echo "   Version: $version"

    if echo "$renderer" | grep -q "NVIDIA"; then
        echo -e "${GREEN}✓ OpenGL using NVIDIA GPU${NC}"
    else
        echo -e "${YELLOW}! OpenGL not using NVIDIA (using: $renderer)${NC}"
    fi
else
    echo -e "${YELLOW}! glxinfo not found (install: mesa-utils)${NC}"
fi
echo ""

# Test 3: Vulkan
echo -e "${BLUE}3. Vulkan Support:${NC}"
if command -v vulkaninfo &>/dev/null; then
    gpu_name=$(vulkaninfo --summary 2>/dev/null | grep "deviceName" | head -1 | cut -d'=' -f2 | xargs)
    driver_name=$(vulkaninfo --summary 2>/dev/null | grep "driverName" | head -1 | cut -d'=' -f2 | xargs)
    echo "   GPU: $gpu_name"
    echo "   Driver: $driver_name"

    if echo "$gpu_name" | grep -q "NVIDIA"; then
        echo -e "${GREEN}✓ Vulkan using NVIDIA GPU${NC}"
    else
        echo -e "${YELLOW}! Vulkan not using NVIDIA${NC}"
    fi
else
    echo -e "${RED}✗ vulkaninfo not found (install: vulkan-tools)${NC}"
fi
echo ""

# Test 4: DRI devices
echo -e "${BLUE}4. DRI Devices:${NC}"
if ls /dev/dri/* &>/dev/null; then
    ls -l /dev/dri/ | grep -E "card|render" | awk '{print "   " $NF}'
    echo -e "${GREEN}✓ DRI devices available${NC}"
else
    echo -e "${RED}✗ No DRI devices found${NC}"
fi
echo ""

# Test 5: Heroic flatpak GPU access
echo -e "${BLUE}5. Heroic Flatpak GPU Access:${NC}"
if flatpak list | grep -q "heroic"; then
    overrides=$(flatpak override --user --show com.heroicgameslauncher.hgl 2>/dev/null)

    if echo "$overrides" | grep -q "devices=all"; then
        echo -e "${GREEN}✓ Device access: enabled${NC}"
    else
        echo -e "${YELLOW}! Device access: not configured${NC}"
    fi

    if echo "$overrides" | grep -q "NVIDIA_VISIBLE_DEVICES"; then
        echo -e "${GREEN}✓ NVIDIA environment: configured${NC}"
    else
        echo -e "${YELLOW}! NVIDIA environment: not configured${NC}"
    fi

    if echo "$overrides" | grep -q "/run/nvidia-xdriver"; then
        echo -e "${GREEN}✓ NVIDIA driver access: enabled${NC}"
    else
        echo -e "${YELLOW}! NVIDIA driver access: not configured${NC}"
    fi
else
    echo -e "${YELLOW}! Heroic not installed${NC}"
fi
echo ""

# Test 6: Test with vkcube
echo -e "${BLUE}6. Vulkan Rendering Test:${NC}"
if command -v vkcube &>/dev/null; then
    echo "   Run 'vkcube' to test Vulkan rendering"
    echo "   (Press ESC to close)"
    read -p "   Run vkcube now? [y/N]: " run_vkcube
    if [[ "$run_vkcube" =~ ^[Yy]$ ]]; then
        vkcube
    fi
else
    echo -e "${YELLOW}! vkcube not found (install: vulkan-tools)${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo ""
echo "GPU acceleration is working if you see:"
echo "  ✓ NVIDIA GPU detected in all tests"
echo "  ✓ Vulkan using NVIDIA"
echo "  ✓ Heroic has device and NVIDIA access"
echo ""
echo "For games:"
echo "  • Steam: GPU acceleration automatic via Proton"
echo "  • Heroic: GPU acceleration now enabled"
echo "  • Monitor GPU usage: nvidia-smi -l 1"
echo ""
