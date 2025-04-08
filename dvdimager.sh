#!/bin/bash

# Check prerequisites
if ! command -v dd &> /dev/null; then
    echo "Install dd first!"
    exit 1
fi

# Set dev variable from user parameter or default to cdrom
dev=${1:-cdrom}

# Check if the chosen device exists
if [ ! -e /dev/"$dev" ]; then
    echo "Device /dev/$dev not found!"
    exit 1
fi

# Fetch media metadata
isoinfo=$(isoinfo -d -i /dev/"$dev" 2>/dev/null)

# Check that previous command succeeded
if [ $? -ne 0 ]; then
    echo "Failed to read isoinfo!"
    exit 1
fi

# Build parameters array
parameters=("if=/dev/$dev")
parameters+=("of=$(echo "$isoinfo" | grep -Po '\bVolume id: \K(.+)\b').iso")
parameters+=("bs=$(echo "$isoinfo" | grep -Po '\bLogical block size is: \K([0-9]+)\b')")
parameters+=("count=$(echo "$isoinfo" | grep -Po '\bVolume size is: \K([0-9]+)\b')")
parameters+=("status=progress")

echo "${parameters[@]}"

# Start actual imaging process
dd "${parameters[@]}"

# Eject media after image is done
eject "/dev/$dev"

echo "Jobs done!"