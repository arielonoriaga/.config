#!/bin/sh
# Add a 2G disk swapfile (idempotent). Run as root: sudo sh add-swapfile.sh
set -e

SWAPFILE=/swapfile
SIZE=2G

if swapon --show=NAME --noheadings | grep -qx "$SWAPFILE"; then
	echo "$SWAPFILE already active"
	swapon --show
	exit 0
fi

[ -f "$SWAPFILE" ] || fallocate -l "$SIZE" "$SWAPFILE"
chmod 600 "$SWAPFILE"
swapon "$SWAPFILE" 2>/dev/null || { mkswap "$SWAPFILE"; swapon "$SWAPFILE"; }
grep -q "^$SWAPFILE " /etc/fstab || echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab

swapon --show
