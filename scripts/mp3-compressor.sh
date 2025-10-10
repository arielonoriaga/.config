#!/bin/bash

show_help() {
  cat << EOF
mp3-compressor - Converts MP3 files to compressed M4A format using AAC encoding

USAGE:
  $0 [input-file-or-directory] [output-directory]
  $0 --help | -h

ARGUMENTS:
  input-file-or-directory    Single MP3 file or directory containing MP3 files (default: current directory)
  output-directory           Directory for output M4A files (default: same as input directory or input file's directory)

OPTIONS:
  --help, -h                 Show this help message

EXAMPLES:
  $0                              # Process MP3s in current directory
  $0 song.mp3                     # Convert single MP3 file to same directory
  $0 song.mp3 /output            # Convert single MP3 file to output directory
  $0 /path/to/mp3s               # Process MP3s from specific input directory
  $0 /path/to/mp3s /output       # Process MP3s from input to specific output directory

DESCRIPTION:
  This script converts MP3 files to M4A format with:
  - Mono audio (1 channel) for smaller file sizes
  - 96k AAC bitrate for good quality/size balance
  - Preserves original filenames with .m4a extension
  
  Supports both single file and directory processing modes.

REQUIREMENTS:
  - ffmpeg must be installed and available in PATH

OUTPUT:
  Creates .m4a files with the same base name as input .mp3 files
EOF
}

# === Check for help flag ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
  exit 0
fi

# Get input (first argument) or current directory
INPUT=${1:-.}

# Check if input is a file or directory
if [ -f "$INPUT" ] && [[ "$INPUT" == *.mp3 ]]; then
  # Single file mode
  INPUT_FILE="$INPUT"
  INPUT_DIR=$(dirname "$INPUT_FILE")
  OUTPUT_FOLDER=${2:-$INPUT_DIR}
  
  mkdir -p "$OUTPUT_FOLDER"
  basename_f=$(basename "$INPUT_FILE")
  echo "Converting: $INPUT_FILE"
  ffmpeg -i "$INPUT_FILE" -ac 1 -c:a aac -b:a 96k "$OUTPUT_FOLDER/${basename_f%.mp3}.m4a"
  
elif [ -d "$INPUT" ]; then
  # Directory mode
  MP3_DIR="$INPUT"
  OUTPUT_FOLDER=${2:-$MP3_DIR}
  
  mkdir -p "$OUTPUT_FOLDER"
  echo "Processing directory: $MP3_DIR"
  
  file_count=0
  for f in "$MP3_DIR"/*.mp3; do
    [ -f "$f" ] || continue
    basename_f=$(basename "$f")
    echo "Converting: $basename_f"
    ffmpeg -i "$f" -ac 1 -c:a aac -b:a 96k "$OUTPUT_FOLDER/${basename_f%.mp3}.m4a"
    ((file_count++))
  done
  
  if [ $file_count -eq 0 ]; then
    echo "No MP3 files found in directory: $MP3_DIR"
    exit 1
  fi
  
else
  echo "Error: '$INPUT' is not a valid MP3 file or directory"
  echo "Use --help for more information"
  exit 1
fi

echo "✅ Conversion complete!"
