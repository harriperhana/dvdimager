#!/bin/bash

header() {
	title="[ $1 ]"
	len=${#title}
	padding=$((($(tput cols) - len) / 2))
	extra=$(($(tput cols) - (padding * 2 + len)))
	echo
	echo
	printf '·%.0s' $(seq 1 $padding)
	echo -n "$title"
	printf '·%.0s' $(seq 1 $((padding + extra)))
	echo
	echo
	echo -ne "\033]0;$1\007"
}

# kekw xD
header "dvdimager"

# Check prerequisites
if ! command -v dd &> /dev/null; then
	echo "Install dd first!"
	echo
	exit 1
fi

# Set dev variable from user parameter or default to cdrom
dev=${1:-cdrom}

# Check if the chosen device exists
if [ ! -e /dev/"$dev" ]; then
	echo "Device /dev/$dev not found!"
	echo
	exit 1
fi

# Fetch media metadata
if ! isoinfo=$(isoinfo -d -i /dev/"$dev" 2>/dev/null); then
	echo "Failed to read isoinfo!"
	echo
	exit 1
fi

# Default output filename
of="$(echo "$isoinfo" | grep -Po '\bVolume id: \K(.+)\b').iso"

# Confirm or change output filename
read -re -i "$of" -p "Output filename: " prompt
if [ -n "$prompt" ]; then
	of="$prompt"
fi

# Handle file existence crisis
while [ -e "$of" ]; do
	echo
	read -rp "File '$of' exists, would you like to [o]verwrite, [r]ename or [c]ancel? " prompt
	case "$prompt" in
		[oO])
			rm -f "$of"
			echo "Existing file removed, continuing..."
			;;
		[rR])
			read -re -i "$of" -p "Enter new filename: " of
			of="$of"
			;;
		[cC])
			echo "All right! Take care now! Bye-bye, then!"
			echo
			exit 0
			;;
		*)
			echo "Invalid command. Come on, you can do this!"
			;;
	esac
done
echo

# Build parameters array
parameters=("if=/dev/$dev")
parameters+=("of=$of")
parameters+=("bs=$(echo "$isoinfo" | grep -Po '\bLogical block size is: \K([0-9]+)\b')")
parameters+=("count=$(echo "$isoinfo" | grep -Po '\bVolume size is: \K([0-9]+)\b')")
parameters+=("status=progress")

# Read disc contents before writing image
# (somewhy this is needed sometimes to prevent dd I/O failures)
echo -n "Reading disc files... "
if isoinfo -i /dev/"$dev" &>/dev/null; then
	echo "OK!"
else
	echo "failed :("
	echo
	exit 1
fi

# Start the actual imaging process
dd "${parameters[@]}"

# Eject media after the image is done
eject "/dev/$dev"

# Check if more action is wanted
while true; do
	echo
	read -p "Moar to read? [y]es, [n]o? " prompt
	case "$prompt" in
		[yY])
			exec bash "$0" "$@"
			;;
		*)
			echo
			echo "Jobs done!"
			echo
			exit 0
			;;
	esac
done