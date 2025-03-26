#!/bin/sh
set -e

if ! [ "$(id -u)" -eq 0 ]; then
	echo -e "\033[1;31mrun as root.\033[0m"
	exit 1
fi

TARGET_DISK="/dev/sda"

# wipe partitions and create a new one with mbr
echo -e "o\nw" | sudo fdisk ${TARGET_DISK}

echo -e "\033[1;31mdisk wiped\033[0m"

echo -e "o\nn\np\n1\n\nt\n83\nw" | sudo fdisk ${TARGET_DISK}

echo -e "\033[1;31mpartition created\033[0m"

mkfs.ext4 ${TARGET_DISK}1

echo -e "\033[1;31minstalled filesystem on partition\033[0m"

mount ${TARGET_DISK}1 /mnt

echo -e "\033[1;31mmounted partition to mnt\033[0m"

# copy the live system over to the new partition
rsync -aAXv / --exclude=/mnt --exclude=/rofs --exclude=/proc --exclude=/sys --exclude=/dev /mnt/

echo -e "\033[1;31mcopied rootfs to partition\033[0m"

# set up grub
grub-install --root-directory=/mnt ${TARGET_DISK}

echo -e "\033[1;31minstalled grub on partition\033[0m"

chroot /mnt grub-mkconfig -o /mnt/boot/grub/grub.cfg

echo -e "\033[1;31mcreated grub config\033[0m"

umount /mnt

echo -e "\033[1;31munmounted partition\033[0m"

echo -e "\033[1;31mlocked and loaded\033[0m"
