#!/usr/bin/env bash

show_help() {
  cat << EOF
copy-clean - Creates a clean copy of a project folder without development artifacts

USAGE:
  $0 <source-folder> <destination-folder>
  $0 --help | -h

ARGUMENTS:
  source-folder       Source project folder to copy
  destination-folder  Destination folder for the clean copy

OPTIONS:
  --help, -h          Show this help message

EXAMPLE:
  $0 my-project clean-project

DESCRIPTION:
  This script creates a clean copy of a project by:
  1. Copying the source folder to destination
  2. Removing development folders: node_modules, .git, .github, dist
  3. Removing checksum and archive files: *.md5, *.sha1, *.zip

USE CASES:
  - Creating clean project copies for sharing
  - Preparing projects for archiving
  - Removing development artifacts before deployment
EOF
}

# === Check for help flag ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
  exit 0
fi

# === Require 2 args ===
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source-folder> <destination-folder>"
  echo "Example: $0 my-project clean-project"
  echo "Use --help for more information"
  exit 1
fi

SRC="$1"
DEST="$2"

# === Check if source folder exists ===
if [ ! -d "$SRC" ]; then
  echo "Error: Source folder '$SRC' does not exist."
  exit 1
fi

# === Copy folder ===
echo "Copying '$SRC' to '$DEST'..."
cp -r "$SRC" "$DEST"

# === Remove unwanted folders from copy ===
echo "Removing node_modules, .git, .github, dist from '$DEST'..."
rm -rf "$DEST/node_modules" "$DEST/.git" "$DEST/.github" "$DEST/dist"

# === Remove md5, sha1, and zip files ===
echo "Removing .md5, .sha1, and .zip files from '$DEST'..."
find "$DEST" -type f \( -iname "*.md5" -o -iname "*.sha1" -o -iname "*.zip" \) -exec rm -f {} \;

echo "✔ Done: Clean copy available at '$DEST'"
