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
