#!/bin/bash

# Firefox launcher optimized for NVIDIA + Wayland with anti-flickering
export MOZ_ENABLE_WAYLAND=1
export MOZ_WAYLAND_USE_VAAPI=1
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_X11_EGL=1

# NVIDIA-specific environment variables
export __GL_SYNC_TO_VBLANK=1
export __GL_GSYNC_ALLOWED=1
export __GL_VRR_ALLOWED=1

# Launch Firefox with hardware acceleration
exec firefox "$@"