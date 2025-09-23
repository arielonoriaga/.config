#!/bin/bash

# Auto-mount script for USB/SD devices
# Usage: auto-mount-usb.sh {add|remove} device_name

ACTION="$1"
DEVNAME="$2"

# Mount point base directory
MOUNT_BASE="/media"

# Get device info
DEVICE=$(basename "$DEVNAME")
UUID=$(blkid -s UUID -o value "$DEVNAME" 2>/dev/null)
LABEL=$(blkid -s LABEL -o value "$DEVNAME" 2>/dev/null)

# Determine mount point name
if [ -n "$LABEL" ]; then
    MOUNT_POINT="$MOUNT_BASE/$LABEL"
elif [ -n "$UUID" ]; then
    MOUNT_POINT="$MOUNT_BASE/$UUID"
else
    MOUNT_POINT="$MOUNT_BASE/$DEVICE"
fi

case "$ACTION" in
    add)
        # Create mount point if it doesn't exist
        mkdir -p "$MOUNT_POINT"
        
        # Get filesystem type
        FSTYPE=$(blkid -s TYPE -o value "$DEVNAME" 2>/dev/null)
        
        # Mount with appropriate options based on filesystem type
        case "$FSTYPE" in
            vfat|fat32|ntfs)
                # Mount FAT32/NTFS with user permissions
                mount -o uid=1000,gid=1000,umask=022 "$DEVNAME" "$MOUNT_POINT"
                ;;
            *)
                # Mount other filesystems normally
                mount "$DEVNAME" "$MOUNT_POINT"
                chown ariel:ariel "$MOUNT_POINT"
                chmod 755 "$MOUNT_POINT"
                ;;
        esac
        
        echo "Mounted $DEVNAME at $MOUNT_POINT"
        ;;
    remove)
        # Unmount if mounted
        if mountpoint -q "$MOUNT_POINT"; then
            umount "$MOUNT_POINT"
            rmdir "$MOUNT_POINT" 2>/dev/null
            echo "Unmounted $MOUNT_POINT"
        fi
        ;;
esac