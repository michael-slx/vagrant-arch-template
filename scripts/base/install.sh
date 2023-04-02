#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

PACKAGES=(
    base
    base-devel
    linux
    e2fsprogs dosfstools efibootmgr
    openssh
    systemd-resolvconf reflector
    virtualbox-guest-utils-nox
    neovim nano wget curl sudo git subversion mercurial
    man-db man-pages texinfo
    zsh bash bash-completion
)

timedatectl set-ntp 1
timedatectl set-timezone Etc/UTC

sfdisk /dev/sda < "${FILES_DIR}/base/disk.sfdisk"
mkfs.vfat -F32 -n EFI /dev/sda1
mkswap -L SWAP /dev/sda2
mkfs.ext4 -L ROOT /dev/sda3

mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

pacstrap -K /mnt "${PACKAGES[@]}"
cp -v "${FILES_DIR}/base/fstab" "/mnt/etc/fstab"

CHROOT_UPLOAD_DIR="/setup"
INNER_SCRIPTS_DIR="$CHROOT_UPLOAD_DIR/scripts"
INNER_FILES_DIR="$CHROOT_UPLOAD_DIR/files"

mkdir -p "/mnt${INNER_SCRIPTS_DIR}" "/mnt${INNER_FILES_DIR}"

cp -R "${SCRIPTS_DIR}"/* "/mnt${INNER_SCRIPTS_DIR}"
cp -R "${FILES_DIR}"/* "/mnt${INNER_FILES_DIR}"

arch-chroot /mnt \
    env \
    SCRIPTS_DIR="${INNER_SCRIPTS_DIR}" \
    FILES_DIR="${INNER_FILES_DIR}" \
    "${INNER_SCRIPTS_DIR}/base/chroot.sh"

ln -sf "/run/systemd/resolve/stub-resolv.conf" /mnt/etc/resolv.conf

rm -Rf "/mnt${CHROOT_UPLOAD_DIR}"
rm -f "/mnt/etc/machine-id"

sync
umount -Rv /mnt
swapoff /dev/sda2
sync
