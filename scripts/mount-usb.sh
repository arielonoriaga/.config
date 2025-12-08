#!/bin/bash

# Script to manually mount any connected USB storage device
# Usage: mount-usb.sh [device_name]

MOUNT_BASE="/media"

# If device name provided, use it
if [ -n "$1" ]; then
    DEVNAME="$1"
    if [ ! -b "$DEVNAME" ]; then
        echo "Error: $DEVNAME is not a valid block device"
        exit 1
    fi
else
    # Find first unmounted USB/removable device
    DEVNAME=""
    for dev in /dev/sd[b-z]* /dev/mmcblk*; do
        if [ -b "$dev" ]; then
            # Check if it's removable
            BASE_DEVICE=$(basename "$dev" | sed 's/[0-9]*p*[0-9]*$//')
            if [ -f "/sys/block/$BASE_DEVICE/removable" ]; then
                REMOVABLE=$(cat "/sys/block/$BASE_DEVICE/removable" 2>/dev/null)
                if [ "$REMOVABLE" = "1" ]; then
                    # Check if it has a filesystem and is not mounted
                    FSTYPE=$(blkid -s TYPE -o value "$dev" 2>/dev/null)
                    if [ -n "$FSTYPE" ] && ! mountpoint -q "$dev" 2>/dev/null && ! mount | grep -q "^$dev "; then
                        DEVNAME="$dev"
                        break
                    fi
                fi
            fi
        fi
    done
    
    if [ -z "$DEVNAME" ]; then
        echo "No unmounted USB storage device found."
        echo ""
        echo "Available block devices:"
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL | grep -E "sd[b-z]|mmcblk|NAME"
        exit 1
    fi
fi

# Get device info
UUID=$(blkid -s UUID -o value "$DEVNAME" 2>/dev/null)
LABEL=$(blkid -s LABEL -o value "$DEVNAME" 2>/dev/null)
FSTYPE=$(blkid -s TYPE -o value "$DEVNAME" 2>/dev/null)
DEVICE=$(basename "$DEVNAME")

# Determine mount point
if [ -n "$LABEL" ]; then
    MOUNT_POINT="$MOUNT_BASE/$LABEL"
elif [ -n "$UUID" ]; then
    MOUNT_POINT="$MOUNT_BASE/$UUID"
else
    MOUNT_POINT="$MOUNT_BASE/$DEVICE"
fi

# Check if already mounted
if mountpoint -q "$MOUNT_POINT" 2>/dev/null || mount | grep -q "^$DEVNAME "; then
    EXISTING_MOUNT=$(mount | grep "^$DEVNAME " | awk '{print $3}' | head -1)
    echo "Device $DEVNAME is already mounted at $EXISTING_MOUNT"
    exit 0
fi

# Create mount point
mkdir -p "$MOUNT_POINT"

# Mount with appropriate options
echo "Mounting $DEVNAME ($FSTYPE) to $MOUNT_POINT..."
case "$FSTYPE" in
    vfat|fat32|ntfs|exfat)
        if mount -o uid=1000,gid=1000,umask=022 "$DEVNAME" "$MOUNT_POINT" 2>&1; then
            echo "Successfully mounted at $MOUNT_POINT"
            echo "Filesystem: $FSTYPE"
            [ -n "$LABEL" ] && echo "Label: $LABEL"
            [ -n "$UUID" ] && echo "UUID: $UUID"
        else
            echo "Failed to mount $DEVNAME"
            rmdir "$MOUNT_POINT" 2>/dev/null
            exit 1
        fi
        ;;
    *)
        if mount "$DEVNAME" "$MOUNT_POINT" 2>&1; then
            chown ariel:ariel "$MOUNT_POINT" 2>/dev/null
            chmod 755 "$MOUNT_POINT" 2>/dev/null
            echo "Successfully mounted at $MOUNT_POINT"
            echo "Filesystem: $FSTYPE"
            [ -n "$LABEL" ] && echo "Label: $LABEL"
            [ -n "$UUID" ] && echo "UUID: $UUID"
        else
            echo "Failed to mount $DEVNAME"
            rmdir "$MOUNT_POINT" 2>/dev/null
            exit 1
        fi
        ;;
esac
