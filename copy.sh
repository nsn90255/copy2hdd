#!/bin/sh
set -e

if ! [ "$(id -u)" -eq 0 ]; then
	echo "run as root."
	exit 1
fi

TARGET_DISK="/dev/sda"

# wipe partitions and create a new one with mbr
echo -e "o\nw" | sudo fdisk ${TARGET_DISK}

echo "disk wiped"

echo -e "o\nn\np\n1\n\nt\n83\nw" | sudo fdisk ${TARGET_DISK}

echo "partition created"

mkfs.ext4 ${TARGET_DISK}1

echo "installed filesystem on partition"

mount ${TARGET_DISK}1 /mnt

echo "mounted partition to mnt"

# copy the live system over to the new partition
rsync -aAXv / --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/dev /mnt/

echo "copied rootfs to partition"

# set up grub
grub-install --root-directory=/mnt ${TARGET_DISK}

echo "installed grub on partition"

chroot /mnt grub-mkconfig -o /mnt/boot/grub/grub.cfg

echo "created grub config"

umount /mnt

echo "unmounted partition"

echo "locked and loaded"
