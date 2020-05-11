#!/bin/bash
set -e
OUT=memtest86+-usb.img

dd if=/dev/zero of="${OUT}" bs=1M count=32
echo -e "n\np\n1\n\n\na\nt\n6\nw" | fdisk "./${OUT}"
sudo losetup -d /dev/loop32 || true
sudo losetup -P /dev/loop32 "${OUT}"
sudo mkdosfs /dev/loop32p1
sudo syslinux /dev/loop32p1
TMPMNT=$(sudo mktemp -d -p /mnt)
sudo mount -tmsdos -o uid=$(id -u),gid=$(id -g) /dev/loop32p1 "${TMPMNT}"
echo -e "default memtest\nlabel memtest\nkernel memtest" > "${TMPMNT}/syslinux.cfg"
cp -a memtest.bin "${TMPMNT}/memtest"

sudo umount "${TMPMNT}"
sudo rmdir "${TMPMNT}"
sudo losetup -d /dev/loop32
dd if=/usr/lib/SYSLINUX/mbr.bin of="${OUT}" conv=notrunc

echo "Success."
exit 0
