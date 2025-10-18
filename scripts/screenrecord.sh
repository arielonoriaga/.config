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
