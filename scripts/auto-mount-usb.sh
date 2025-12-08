#!/bin/bash

# Auto-mount script for USB/SD devices
# Usage: auto-mount-usb.sh {add|remove} device_name

ACTION="$1"
DEVNAME="$2"

# Log file for debugging
LOG_FILE="/tmp/auto-mount-usb.log"
echo "$(date): ACTION=$ACTION DEVNAME=$DEVNAME" >> "$LOG_FILE"

# Mount point base directory
MOUNT_BASE="/media"

# Validate device name
if [ -z "$DEVNAME" ]; then
    echo "$(date): Error: No device name provided" >> "$LOG_FILE"
    exit 1
fi

# Wait a moment for device to be ready (udev timing issue)
sleep 0.5

# Check if device exists
if [ ! -b "$DEVNAME" ]; then
    echo "$(date): Error: Device $DEVNAME does not exist or is not a block device" >> "$LOG_FILE"
    exit 1
fi

# Get device info
DEVICE=$(basename "$DEVNAME")

# Extract base device name (without partition number) for removable check
BASE_DEVICE=$(echo "$DEVICE" | sed 's/[0-9]*$//')

# Check if device is removable (USB/SD card)
# Also exclude devices already mounted at system locations
IS_REMOVABLE=0
if [ -f "/sys/block/$BASE_DEVICE/removable" ]; then
    REMOVABLE=$(cat "/sys/block/$BASE_DEVICE/removable" 2>/dev/null)
    if [ "$REMOVABLE" = "1" ]; then
        IS_REMOVABLE=1
    fi
fi

# Also check if device is already mounted at a system location (like /home, /, /boot)
if mount | grep -q "^$DEVNAME.*on /\(home\|boot\|\) "; then
    echo "$(date): Skipping $DEVNAME - already mounted at system location" >> "$LOG_FILE"
    exit 0
fi

# Skip if not removable (internal drive)
if [ $IS_REMOVABLE -eq 0 ]; then
    echo "$(date): Skipping $DEVNAME - not a removable device" >> "$LOG_FILE"
    exit 0
fi

# Try to get filesystem info with retries (device might not be ready immediately)
UUID=""
LABEL=""
FSTYPE=""
for i in {1..5}; do
    UUID=$(blkid -s UUID -o value "$DEVNAME" 2>/dev/null)
    LABEL=$(blkid -s LABEL -o value "$DEVNAME" 2>/dev/null)
    FSTYPE=$(blkid -s TYPE -o value "$DEVNAME" 2>/dev/null)
    
    if [ -n "$FSTYPE" ]; then
        break
    fi
    sleep 0.2
done

# If still no filesystem type, device might not be formatted
if [ -z "$FSTYPE" ]; then
    echo "$(date): Warning: No filesystem detected on $DEVNAME, skipping mount" >> "$LOG_FILE"
    exit 0
fi

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
        # Check if already mounted
        if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
            echo "$(date): Device $DEVNAME already mounted at $MOUNT_POINT" >> "$LOG_FILE"
            exit 0
        fi
        
        # Create mount point if it doesn't exist
        mkdir -p "$MOUNT_POINT"
        
        # Mount with appropriate options based on filesystem type
        MOUNT_SUCCESS=0
        case "$FSTYPE" in
            vfat|fat32|ntfs|exfat)
                # Mount FAT32/NTFS/exFAT with user permissions
                if mount -o uid=1000,gid=1000,umask=022 "$DEVNAME" "$MOUNT_POINT" 2>>"$LOG_FILE"; then
                    MOUNT_SUCCESS=1
                fi
                ;;
            *)
                # Mount other filesystems normally
                if mount "$DEVNAME" "$MOUNT_POINT" 2>>"$LOG_FILE"; then
                    chown ariel:ariel "$MOUNT_POINT" 2>/dev/null
                    chmod 755 "$MOUNT_POINT" 2>/dev/null
                    MOUNT_SUCCESS=1
                fi
                ;;
        esac
        
        if [ $MOUNT_SUCCESS -eq 1 ]; then
            echo "$(date): Successfully mounted $DEVNAME ($FSTYPE) at $MOUNT_POINT" >> "$LOG_FILE"
        else
            echo "$(date): Failed to mount $DEVNAME at $MOUNT_POINT" >> "$LOG_FILE"
            rmdir "$MOUNT_POINT" 2>/dev/null
            exit 1
        fi
        ;;
    remove)
        # Find the actual mount point for this device
        ACTUAL_MOUNT=$(mount | grep "^$DEVNAME " | awk '{print $3}' | head -1)
        
        if [ -n "$ACTUAL_MOUNT" ]; then
            # Device is mounted, unmount it
            if umount "$ACTUAL_MOUNT" 2>>"$LOG_FILE"; then
                rmdir "$ACTUAL_MOUNT" 2>/dev/null
                echo "$(date): Successfully unmounted $DEVNAME from $ACTUAL_MOUNT" >> "$LOG_FILE"
            else
                echo "$(date): Failed to unmount $DEVNAME from $ACTUAL_MOUNT" >> "$LOG_FILE"
                exit 1
            fi
        else
            # Try the expected mount point as fallback
            if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
                if umount "$MOUNT_POINT" 2>>"$LOG_FILE"; then
                    rmdir "$MOUNT_POINT" 2>/dev/null
                    echo "$(date): Successfully unmounted $MOUNT_POINT" >> "$LOG_FILE"
                else
                    echo "$(date): Failed to unmount $MOUNT_POINT" >> "$LOG_FILE"
                    exit 1
                fi
            else
                echo "$(date): $DEVNAME is not mounted (checked $MOUNT_POINT and mount table)" >> "$LOG_FILE"
                exit 0
            fi
        fi
        ;;
    *)
        echo "$(date): Error: Invalid action '$ACTION'. Use 'add' or 'remove'" >> "$LOG_FILE"
        exit 1
        ;;
esac