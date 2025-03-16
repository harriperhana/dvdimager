#!/bin/bash

if ! command -v dd &> /dev/null; then
    echo "Install dd first!"
    exit 1
fi

dev=${1:-cdrom}

if [ ! -e /dev/"$dev" ]; then
    echo "Device /dev/$dev not found!"
    exit 1
fi

isoinfo=$(isoinfo -d -i /dev/"$dev" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Failed to read isoinfo!"
    exit 1
fi

parameters=("if=/dev/$dev")
parameters+=("of=$(echo "$isoinfo" | grep -Po '\bVolume id: \K(.+)\b').iso")
parameters+=("bs=$(echo "$isoinfo" | grep -Po '\bLogical block size is: \K([0-9]+)\b')")
parameters+=("count=$(echo "$isoinfo" | grep -Po '\bVolume size is: \K([0-9]+)\b')")
parameters+=("status=progress")

echo "${parameters[@]}"

dd "${parameters[@]}"

eject "/dev/$dev"

echo "Jobs done!"