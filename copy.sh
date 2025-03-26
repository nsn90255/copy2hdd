#!/bin/sh

TARGET_DISK="/dev/sda"

mount ${TARGET_DISK}1 /mnt

rsync -aAXv / --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/dev /mnt/

grub-install --root-directory=/mnt ${TARGET_DISK}

chroot /mnt grub-mkconfig -o /mnt/boot/grub/grub.cfg

umount /mnt
echo "locked and loaded"
