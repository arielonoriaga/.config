#!/bin/bash

# Brave browser launcher with anti-flickering flags for NVIDIA + Wayland
export ELECTRON_OZONE_PLATFORM_HINT=auto

# CRITICAL FIX: Unset GBM_BACKEND for screen sharing to work with PipeWire
# The nvidia-drm backend breaks WebRTC screen capture on Wayland
unset GBM_BACKEND

# NVIDIA-specific flags to prevent scrolling flickers
NVIDIA_FLAGS=(
    --disable-gpu-sandbox
    --disable-software-rasterizer
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    --use-gl=egl
    --enable-features=VaapiVideoDecoder,VaapiVideoEncoder
)

# Wayland-specific flags with screen sharing support
WAYLAND_FLAGS=(
    --enable-wayland-ime
    --ozone-platform=wayland
    --enable-wayland-fractional-scale-v1
    --enable-features=WebRTCPipeWireCapturer,WaylandWindowDecorations
)

# Low-latency scrolling and rendering optimization flags
SCROLL_FLAGS=(
    --disable-background-timer-throttling
    --disable-backgrounded-occluded-windows-throttling
    --disable-renderer-backgrounding
    --disable-features=TranslateUI
    --enable-smooth-scrolling
    --force-device-scale-factor=1
    --disable-frame-rate-limit
    --max-gum-fps=120
    --enable-gpu-memory-buffer-compositor-resources
    --enable-gpu-memory-buffer-video-frames
    --enable-native-gpu-memory-buffers
    --enable-oop-rasterization
    --disable-background-mode
    --disable-extensions-http-throttling
)

# Additional low-latency flags
LATENCY_FLAGS=(
    --disable-blink-features=PaintHolding
    --disable-composited-antialiasing
    --disable-partial-raster
    --enable-defer-all-script-without-optimization-hints
    --enable-experimental-canvas-features
    --canvas-oop-rasterization
    --enable-raw-draw
    --disable-threaded-scrolling=false
)

# Launch Brave with all optimization flags
exec brave "${NVIDIA_FLAGS[@]}" "${WAYLAND_FLAGS[@]}" "${SCROLL_FLAGS[@]}" "${LATENCY_FLAGS[@]}" "$@"