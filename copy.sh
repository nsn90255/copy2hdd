#!/bin/sh
set -e

if ! [ "$(id -u)" -eq 0 ]; then
	echo "run as root."
	exit 1
fi

TARGET_DISK="/dev/sda"

# wipe partitions and create a new one with mbr
echo -e "o\nw" | sudo fdisk ${TARGET_DISK}

echo -e "o\nn\np\n1\n\nt\n83\nw" | sudo fdisk ${TARGET_DISK}

mkfs.ext4 ${TARGET_DISK}1

mount ${TARGET_DISK}1 /mnt

# copy the live system over to the new partition
rsync -aAXv / --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/dev /mnt/

# set up grub
grub-install --root-directory=/mnt ${TARGET_DISK}

chroot /mnt grub-mkconfig -o /mnt/boot/grub/grub.cfg

umount /mnt
echo "locked and loaded"
