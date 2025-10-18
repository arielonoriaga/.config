#!/bin/bash

# Screen Recorder Setup Script for Arch Linux + Sway
# This script installs and configures wf-recorder with hardware acceleration

set -e

echo "=== Screen Recorder Setup for Sway ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Error: This script is designed for Arch Linux${NC}"
    exit 1
fi

# Check if running Sway
if ! pgrep -x sway > /dev/null; then
    echo -e "${YELLOW}Warning: Sway is not currently running${NC}"
    echo "The script will continue, but keybindings won't work until you restart Sway"
    echo ""
fi

# Install required packages
echo -e "${GREEN}[1/5] Installing required packages...${NC}"
sudo pacman -S --needed --noconfirm \
    wf-recorder \
    slurp \
    libva-utils \
    intel-media-driver \
    libnotify \
    jq

echo ""
echo -e "${GREEN}[2/5] Creating directories...${NC}"
mkdir -p ~/Videos/Recordings
mkdir -p ~/.config/scripts

echo ""
echo -e "${GREEN}[3/5] Creating recording scripts...${NC}"

# Create hardware-accelerated recording script
cat > ~/.config/scripts/screenrecord.sh << 'EOF'
#!/bin/bash

# wf-recorder wrapper with hardware acceleration
# Usage: screenrecord.sh [area|fullscreen] [audio|noaudio]

MODE="${1:-area}"
AUDIO="${2:-audio}"
OUTPUT_DIR="$HOME/Videos/Recordings"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/recording_$TIMESTAMP.mp4"
LOGFILE="/tmp/wf-recorder.log"
PIDFILE="/tmp/wf-recorder.pid"

mkdir -p "$OUTPUT_DIR"

# Check if already recording
if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    # Stop recording
    PID=$(cat "$PIDFILE")
    kill -INT "$PID"
    rm "$PIDFILE"
    notify-send "Screen Recording" "Recording stopped and saved to:\n$OUTPUT_FILE" -t 5000
    exit 0
fi

# Get geometry
if [ "$MODE" = "area" ]; then
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then
        notify-send "Screen Recording" "Recording cancelled" -t 3000
        exit 1
    fi
    GEO_ARGS="-g $GEOMETRY"
else
    GEO_ARGS=""
fi

# Audio setup
if [ "$AUDIO" = "audio" ]; then
    AUDIO_DEVICE=$(pactl list sources short | grep -v monitor | grep -v easyeffects | head -n1 | awk '{print $2}')
    if [ -n "$AUDIO_DEVICE" ]; then
        AUDIO_ARGS="--audio=$AUDIO_DEVICE"
    else
        AUDIO_ARGS="--audio"
    fi
else
    AUDIO_ARGS=""
fi

# Start recording with hardware acceleration
notify-send "Screen Recording" "Recording started..." -t 3000

wf-recorder \
    $GEO_ARGS \
    $AUDIO_ARGS \
    --codec h264_vaapi \
    --device /dev/dri/renderD128 \
    --file "$OUTPUT_FILE" \
    > "$LOGFILE" 2>&1 &

echo $! > "$PIDFILE"
EOF

# Create simple software fallback script
cat > ~/.config/scripts/screenrecord-simple.sh << 'EOF'
#!/bin/bash

# Simple wf-recorder wrapper (software encoding)
# Usage: screenrecord-simple.sh [area|fullscreen]

MODE="${1:-area}"
OUTPUT_DIR="$HOME/Videos/Recordings"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/recording_$TIMESTAMP.mp4"
PIDFILE="/tmp/wf-recorder-simple.pid"

mkdir -p "$OUTPUT_DIR"

# Check if already recording
if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    PID=$(cat "$PIDFILE")
    kill -INT "$PID"
    rm "$PIDFILE"
    notify-send "Screen Recording" "Recording stopped" -t 3000
    exit 0
fi

# Get geometry
if [ "$MODE" = "area" ]; then
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then
        notify-send "Screen Recording" "Recording cancelled" -t 3000
        exit 1
    fi
    GEO_ARGS="-g $GEOMETRY"
else
    GEO_ARGS=""
fi

notify-send "Screen Recording" "Recording started..." -t 3000

wf-recorder $GEO_ARGS --file "$OUTPUT_FILE" &
echo $! > "$PIDFILE"
EOF

chmod +x ~/.config/scripts/screenrecord.sh
chmod +x ~/.config/scripts/screenrecord-simple.sh

echo ""
echo -e "${GREEN}[4/5] Configuring Sway keybindings...${NC}"

# Backup Sway config
if [ -f ~/.config/sway/config ]; then
    cp ~/.config/sway/config ~/.config/sway/config.backup.$(date +%s)
fi

# Check if keybindings already exist
if ! grep -q "screenrecord.sh" ~/.config/sway/config 2>/dev/null; then
    cat >> ~/.config/sway/config << 'EOF'

# Screen recording keybindings
bindsym $mod+Shift+r exec ~/.config/scripts/screenrecord.sh area audio
bindsym $mod+Shift+Ctrl+r exec ~/.config/scripts/screenrecord.sh fullscreen audio
bindsym $mod+Shift+Alt+r exec ~/.config/scripts/screenrecord.sh area noaudio
EOF
    echo "Keybindings added to Sway config"
else
    echo "Keybindings already exist in Sway config"
fi

echo ""
echo -e "${GREEN}[5/5] Verifying hardware acceleration support...${NC}"
if vainfo > /dev/null 2>&1; then
    echo -e "${GREEN}✓ VA-API hardware acceleration is available${NC}"
    vainfo | grep -i "h264"
else
    echo -e "${YELLOW}⚠ VA-API not working, using software encoding fallback${NC}"
fi

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Keybindings:"
echo "  Mod+Shift+r           - Record selected area (with audio)"
echo "  Mod+Shift+Ctrl+r      - Record fullscreen (with audio)"
echo "  Mod+Shift+Alt+r       - Record selected area (no audio)"
echo ""
echo "Press the same keybinding again to stop recording."
echo ""
echo "Recordings will be saved to: ~/Videos/Recordings/"
echo ""
echo "Next steps:"
echo "  1. Reload Sway config: swaymsg reload (or Mod+Shift+c)"
echo "  2. Test recording with: Mod+Shift+r"
echo ""
echo "Scripts created:"
echo "  ~/.config/scripts/screenrecord.sh (hardware-accelerated)"
echo "  ~/.config/scripts/screenrecord-simple.sh (software fallback)"
echo ""
