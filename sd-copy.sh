#!/bin/bash

# Daemon to monitor a device and sync its contents to a specified directory

# Define the mount point and output directory
MOUNT_POINT="/mnt/sd-card"
OUTPUT_DIR="/export/HDD/imports"

# Function to get the current date and time
get_datetime() {
    echo $(date '+%d-%m-%Y_%-H-%M-%S')
}

# Function to find the biggest partition on /dev/mmcblk0
find_biggest_partition() {
    # Find all partitions on /dev/mmcblk0, sort them by size, and get the biggest one
    local biggest_partition=$(lsblk -lno NAME,SIZE | grep 'mmcblk0p' | sort -hr -k2 | head -n1 | cut -d' ' -f1)
    echo "/dev/$biggest_partition"
}

# Function to perform the mounting, rsyncing, and unmounting
sync_sd() {
    # Find the biggest partition
    local partition=$(find_biggest_partition)
    
    # Create a new directory with the current date and time
    datetime=$(get_datetime)
    new_dir="${OUTPUT_DIR}/${datetime}"
    mkdir -p "$new_dir" || { echo "Error: Failed to create directory."; exit 1; }

    # Set the directory permissions to drwxrwsr-x
    chmod 2775 "$new_dir" || { echo "Error: Failed to set directory permissions."; exit 1; }

    # Mount the biggest partition of the SD card
    if mount "$partition" "${MOUNT_POINT}"; then
        # Rsync contents, excluding dot files, and set permissions
        rsync -rv --progress --exclude '.*' --chmod=D2755,F2755 "${MOUNT_POINT}/" "$new_dir" || { echo "Error: Rsync failed."; umount "${MOUNT_POINT}"; exit 1; }

        # Change the owner to root and group to users
        chown -R root:users "$new_dir" || { echo "Error: Failed to set ownership."; umount "${MOUNT_POINT}"; exit 1; }
        
        # Unmount the SD card
        umount "${MOUNT_POINT}" || { echo "Error: Failed to unmount."; exit 1; }
    else
        echo "Error: Failed to mount $partition."
    fi
}

# Main daemon loop
while true; do
    # Check if /dev/mmcblk0 is connected
    if [ -b /dev/mmcblk0 ]; then
        # Perform the sync
        sync_sd

        # Wait for the SD card to be removed
        while [ -b /dev/mmcblk0 ]; do
            sleep 1
        done
    fi
    sleep 1
done
