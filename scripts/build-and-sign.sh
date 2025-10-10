#!/usr/bin/env bash

show_help() {
  cat << EOF
build-and-sign - Creates a clean, signed build package with integrity verification

USAGE:
  $0 <source-folder> <output-prefix>
  $0 --help | -h

ARGUMENTS:
  source-folder    Source project folder to build and sign
  output-prefix    Prefix for output files (zip, md5, sha1)

OPTIONS:
  --help, -h       Show this help message

EXAMPLE:
  $0 my-project dragon-dance-build

DESCRIPTION:
  This script creates a clean build package by:
  1. Creating a clean copy (removes node_modules, .git, .github, dist)
  2. Removing existing checksum and archive files
  3. Generating MD5 and SHA1 checksums for all files
  4. Creating a ZIP archive of the clean copy
  5. Cleaning up temporary files

OUTPUT FILES:
  {prefix}.zip     Clean archive of the project
  {prefix}.md5     MD5 checksums for all files
  {prefix}.sha1    SHA1 checksums for all files
EOF
}

# === Check for help flag ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
  exit 0
fi

# === Require 2 args ===
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source-folder> <output-prefix>"
  echo "Example: $0 my-project dragon-dance-build"
  echo "Use --help for more information"
  exit 1
fi

SOURCE="$1"
PREFIX="$2"
CLEANED="${PREFIX}-clean"

# === Step 1: Copy clean version ===
echo "🧹 Copying clean version to '${CLEANED}'..."
cp -r "$SOURCE" "$CLEANED"
rm -rf "$CLEANED/node_modules" "$CLEANED/.git" "$CLEANED/.github" "$CLEANED/dist"
find "$CLEANED" -type f \( -iname "*.md5" -o -iname "*.sha1" -o -iname "*.zip" \) -exec rm -f {} \;

# === Step 2: Generate .md5 and .sha1 for all files in clean copy ===
echo "🔏 Generating checksums..."
find "$CLEANED" -type f -exec md5sum {} \; > "${PREFIX}.md5"
find "$CLEANED" -type f -exec sha1sum {} \; > "${PREFIX}.sha1"

# === Step 3: Zip the cleaned copy (exclude the generated .md5/.sha1) ===
echo "📦 Creating zip: ${PREFIX}.zip..."
zip -r "${PREFIX}.zip" "$CLEANED" > /dev/null

# === Step 4: Clean up clean copy ===
echo "🧹 Removing temp cleaned folder: $CLEANED"
rm -rf "$CLEANED"

# === Done ===
echo "✅ All done:"
echo " → ${PREFIX}.zip"
echo " → ${PREFIX}.md5"
echo " → ${PREFIX}.sha1"
