#!/bin/bash
# Hardcoded HDMI selection for screen sharing
logfile="/tmp/xdg-portal-chooser.log"
echo "=== Chooser called at $(date) ===" >> "$logfile"
echo "Input:" >> "$logfile"
input=$(cat)
echo "$input" >> "$logfile"

# Hardcoded HDMI output
output="HDMI-A-2"
echo "Hardcoded output: $output" >> "$logfile"
echo "$output"
