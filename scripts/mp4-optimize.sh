#!/bin/bash

show_help() {
  cat << EOF
mp4-optimizer - Optimizes MP4 videos for Phaser 3 games with iOS compatibility

USAGE:
  $0 [input-file-or-directory] [output-directory] [quality]
  $0 --help | -h

ARGUMENTS:
  input-file-or-directory    Single MP4 file or directory containing MP4 files (default: current directory)
  output-directory           Directory for output MP4 files (default: same as input directory or input file's directory)
  quality                    Quality preset: high, medium, low, web (default: web)

OPTIONS:
  --help, -h                 Show this help message

QUALITY PRESETS:
  high     Best quality, larger file size (CRF 18, 1080p max)
  medium   Balanced quality/size (CRF 23, 720p max) 
  low      Smaller files, acceptable quality (CRF 28, 480p max)
  web      iOS-optimized for web games (CRF 25, 720p max, strict compatibility)

EXAMPLES:
  $0                                    # Optimize MP4s in current directory (web quality)
  $0 video.mp4                         # Optimize single MP4 file (web quality)
  $0 video.mp4 /output                 # Optimize single MP4 to output directory
  $0 video.mp4 /output high           # Optimize with high quality preset
  $0 /videos /output web              # Optimize directory with web preset

DESCRIPTION:
  This script optimizes MP4 videos specifically for Phaser 3 games with iOS compatibility:
  
  iOS WEB COMPATIBILITY FEATURES:
  - H.264 baseline profile (level 3.0) - maximum iOS compatibility
  - AAC-LC audio codec - iOS standard
  - Moov atom moved to front for fast streaming
  - Progressive download support
  - Specific pixel format (yuv420p) for hardware acceleration
  - Frame rate optimization (30fps max for better performance)
  - Resolution limits to prevent iOS memory issues
  
  PHASER 3 OPTIMIZATIONS:
  - File size reduction for faster loading
  - Consistent frame rates for smooth playback
  - Audio sync preservation
  - Web-friendly encoding settings

REQUIREMENTS:
  - ffmpeg must be installed and available in PATH

OUTPUT:
  Creates optimized .mp4 files with "_optimized" suffix
  Original files are preserved unless overwriting same directory

IOS TROUBLESHOOTING:
  - If videos don't play on iOS Safari, try the 'web' quality preset
  - Large videos (>100MB) may cause memory issues on older iOS devices
  - Videos over 1080p may not play smoothly on older devices
  - Use muted autoplay for iOS compatibility in Phaser games
EOF
}

# === Check for help flag ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
  exit 0
fi

# Get input (first argument) or current directory
INPUT=${1:-.}
OUTPUT_DIR=${2}
QUALITY=${3:-web}

# Validate quality preset
case $QUALITY in
  high|medium|low|web)
    ;;
  *)
    echo "Error: Invalid quality preset '$QUALITY'"
    echo "Valid options: high, medium, low, web"
    echo "Use --help for more information"
    exit 1
    ;;
esac

# Set encoding parameters based on quality preset
set_quality_params() {
  case $QUALITY in
    high)
      CRF=18
      MAX_WIDTH=1920
      MAX_HEIGHT=1080
      BITRATE="5000k"
      AUDIO_BITRATE="192k"
      ;;
    medium)
      CRF=23
      MAX_WIDTH=1280
      MAX_HEIGHT=720
      BITRATE="2500k"
      AUDIO_BITRATE="128k"
      ;;
    low)
      CRF=28
      MAX_WIDTH=854
      MAX_HEIGHT=480
      BITRATE="1000k"
      AUDIO_BITRATE="96k"
      ;;
    web)
      CRF=25
      MAX_WIDTH=1280
      MAX_HEIGHT=720
      BITRATE="1500k"
      AUDIO_BITRATE="128k"
      ;;
  esac
}

convert_video() {
  local input_file="$1"
  local output_file="$2"
  
  echo "Converting: $(basename "$input_file") [Quality: $QUALITY]"
  
  # iOS-compatible encoding with Phaser 3 optimizations
  ffmpeg -i "$input_file" \
    -c:v libx264 \
    -profile:v baseline \
    -level:v 3.0 \
    -crf $CRF \
    -maxrate $BITRATE \
    -bufsize $(( ${BITRATE%k} * 2 ))k \
    -vf "scale='min($MAX_WIDTH,iw)':'min($MAX_HEIGHT,ih)':force_original_aspect_ratio=decrease,fps=30" \
    -pix_fmt yuv420p \
    -c:a aac \
    -b:a $AUDIO_BITRATE \
    -ac 2 \
    -ar 44100 \
    -movflags +faststart \
    -preset slow \
    -tune film \
    -y \
    "$output_file"
    
  if [ $? -eq 0 ]; then
    # Get file sizes for comparison
    local original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
    local optimized_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)
    
    if [ -n "$original_size" ] && [ -n "$optimized_size" ]; then
      local reduction=$((100 - (optimized_size * 100 / original_size)))
      echo "  ✓ Size reduction: ${reduction}% ($(numfmt --to=iec $original_size) → $(numfmt --to=iec $optimized_size))"
    else
      echo "  ✓ Optimization complete"
    fi
  else
    echo "  ✗ Failed to convert $(basename "$input_file")"
    return 1
  fi
}

# Set quality parameters
set_quality_params

# Check if input is a file or directory
if [ -f "$INPUT" ] && [[ "$INPUT" == *.mp4 ]]; then
  # Single file mode
  INPUT_FILE="$INPUT"
  INPUT_DIR=$(dirname "$INPUT_FILE")
  OUTPUT_FOLDER=${OUTPUT_DIR:-$INPUT_DIR}
  
  mkdir -p "$OUTPUT_FOLDER"
  basename_f=$(basename "$INPUT_FILE" .mp4)
  output_file="$OUTPUT_FOLDER/${basename_f}_optimized.mp4"
  
  convert_video "$INPUT_FILE" "$output_file"
  
elif [ -d "$INPUT" ]; then
  # Directory mode
  MP4_DIR="$INPUT"
  OUTPUT_FOLDER=${OUTPUT_DIR:-$MP4_DIR}
  
  mkdir -p "$OUTPUT_FOLDER"
  echo "Processing directory: $MP4_DIR [Quality: $QUALITY]"
  echo ""
  
  file_count=0
  success_count=0
  
  for f in "$MP4_DIR"/*.mp4; do
    [ -f "$f" ] || continue
    basename_f=$(basename "$f" .mp4)
    output_file="$OUTPUT_FOLDER/${basename_f}_optimized.mp4"
    
    if convert_video "$f" "$output_file"; then
      ((success_count++))
    fi
    ((file_count++))
    echo ""
  done
  
  if [ $file_count -eq 0 ]; then
    echo "No MP4 files found in directory: $MP4_DIR"
    exit 1
  fi
  
  echo "Processed $success_count/$file_count files successfully"
  
else
  echo "Error: '$INPUT' is not a valid MP4 file or directory"
  echo "Use --help for more information"
  exit 1
fi

echo ""
echo "🎮 Optimization complete! Videos are ready for Phaser 3 + iOS"
echo ""
echo "💡 Phaser 3 Tips:"
echo "   - Use muted autoplay for iOS compatibility"
echo "   - Preload videos in Phaser's preload scene"
echo "   - Consider using video sprites for better performance"
echo ""
echo "📱 iOS Tips:"
echo "   - Test on actual iOS devices, not just simulator"
echo "   - Videos over 100MB may cause memory issues"
echo "   - Use user interaction to start video playback when possible"
