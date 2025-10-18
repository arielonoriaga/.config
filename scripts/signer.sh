#!/usr/bin/env bash

show_help() {
  cat << EOF
signer - Generates integrity checksums for files in a folder

USAGE:
  $0 <folder> <prefix>
  $0 --help | -h

ARGUMENTS:
  folder    Directory containing files to generate checksums for
  prefix    Prefix for output checksum files

OPTIONS:
  --help, -h    Show this help message

EXAMPLE:
  $0 dist dragon-dance-build

DESCRIPTION:
  This script generates integrity checksums for all files in a directory:
  - MD5 checksums for fast integrity verification
  - SHA1 checksums for stronger cryptographic verification
  
  Useful for verifying file integrity during transfers or deployments.

OUTPUT FILES:
  {prefix}.md5     MD5 checksums for all files
  {prefix}.sha1    SHA1 checksums for all files

USE CASES:
  - Verifying file integrity after transfers
  - Creating checksums for release packages
  - Ensuring deployment integrity
EOF
}

# === Check for help flag ===
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  show_help
  exit 0
fi

# === Require 2 args ===
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <folder> <prefix>"
  echo "Example: $0 dist dragon-dance-build"
  echo "Use --help for more information"
  exit 1
fi

FOLDER="$1"
PREFIX="$2"

# === Check if folder exists ===
if [ ! -d "$FOLDER" ]; then
  echo "Error: Folder '$FOLDER' does not exist."
  exit 1
fi

# === Generate Hash Files ===
echo "Generating checksums for folder: $FOLDER"
find "$FOLDER" -type f -exec md5sum {} \; > "${PREFIX}.md5"
find "$FOLDER" -type f -exec sha1sum {} \; > "${PREFIX}.sha1"

echo "✔ Done:"
echo " → ${PREFIX}.md5"
echo " → ${PREFIX}.sha1"
