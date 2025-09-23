#!/bin/bash

# Low-latency Wayland environment configuration for NVIDIA hybrid graphics
# Source this before starting Sway: source ~/.config/low-latency-wayland.sh

# Core Wayland renderer optimization
export WLR_RENDERER=vulkan
export WLR_NO_HARDWARE_CURSORS=1

# NVIDIA-specific optimizations for lower latency
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export LIBVA_DRIVER_NAME=nvidia

# Reduced buffering for lower input lag
export WLR_DRM_DEVICES="/dev/dri/card0:/dev/dri/card1"

# Critical anti-flicker settings (keep these to prevent flickering)
export WLR_DRM_NO_ATOMIC=1
export WLR_DRM_NO_MODIFIERS=1
export NVIDIA_WAYLAND_USE_DISPLAYLINK=0

# Low-latency optimizations
export XWAYLAND_NO_GLAMOR=1
export WLR_SCENE_DISABLE_VISIBILITY=0

# Performance optimizations
export __GL_THREADED_OPTIMIZATIONS=1
export __GL_SHADER_CACHE=1
export __GL_SYNC_TO_VBLANK=0

echo "Low-latency Wayland environment configured for NVIDIA hybrid graphics"