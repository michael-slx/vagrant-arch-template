#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd.service

echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=us' > /etc/vconsole.conf

echo 'vagrant' > /etc/hostname
echo '127.0.0.1   localhost' >> /etc/hosts
echo '::1         localhost' >> /etc/hosts

cp "$FILES_DIR/base/default-wired.network" "/etc/systemd/network/20-default-wired.network"
systemctl enable systemd-networkd.service systemd-resolved.service

ZSH_BINARY="$(chsh -l | grep zsh | head -1)"

chsh -s "$ZSH_BINARY"
touch /root/.zshrc

useradd -m -s "$ZSH_BINARY" vagrant

cat <<eof | chpasswd
root:vagrant
vagrant:vagrant
eof

git clone https://github.com/ohmyzsh/ohmyzsh.git /home/vagrant/.oh-my-zsh
cp $FILES_DIR/base/zshrc /home/vagrant/.zshrc
chown -R vagrant:vagrant /home/vagrant/.oh-my-zsh /home/vagrant/.zshrc

cp -R /home/vagrant/.oh-my-zsh /root/.oh-my-zsh
cp $FILES_DIR/base/zshrc /root/.zshrc
chown -R root:root /root/.oh-my-zsh /root/.zshrc

mkdir -p /home/vagrant/.ssh
cat $FILES_DIR/base/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
systemctl enable sshd

cp -f $FILES_DIR/base/sudoers /etc/sudoers
chmod 440 /etc/sudoers

sed -i '/^#.*CheckSpace/s/^#//' /etc/pacman.conf
sed -i '/^#.*Color/s/^#//' /etc/pacman.conf
sed -i '/^#.*VerbosePkgLists/s/^#//' /etc/pacman.conf

sed -i '/^#NoExtract/s/^#//' /etc/pacman.conf
sed -i '/^NoExtract /s/$/ pacman-mirrorlist/' /etc/pacman.conf

systemctl enable vboxservice.service
systemctl mask systemd-remount-fs.service systemd-fsck-root.service

cp $FILES_DIR/base/reflector.conf /etc/xdg/reflector/reflector.conf
cp $FILES_DIR/base/reflector-firstboot.service /usr/lib/systemd/system/reflector-firstboot.service
systemctl enable reflector.timer reflector-firstboot.service

[[ -d /boot/EFI/BOOT ]] || mkdir -p /boot/EFI/BOOT
[[ -d /etc/kernel ]] || mkdir -p /etc/kernel
echo 'root=LABEL=ROOT resume=LABEL=SWAP rootflags=rw fsck.mode=skip nomodeset quiet' > /etc/kernel/cmdline
cp $FILES_DIR/base/mkinitcpio.conf /etc/mkinitcpio.conf
cp $FILES_DIR/base/mkinitcpio-linux.preset /etc/mkinitcpio.d/linux.preset
mkinitcpio -P linux
[[ -f "/boot/EFI/BOOT/BOOTX64.EFI" ]] || exit 5
efibootmgr --create --disk /dev/sda --part 1 --loader '/EFI/BOOT/BOOTX64.EFI' --label "Arch Linux"

su - vagrant \
    "${SCRIPTS_DIR}/base/aur-install.sh"
su - vagrant \
    "${SCRIPTS_DIR}/user.sh" \
    "${SCRIPTS_DIR}" \
    "${FILES_DIR}"

UNUSED_PKGS=$(pacman -Qdtq || true)
if [[ ! -z "$UNUSED_PKGS" ]]; then
  pacman -Rs --noconfirm $UNUSED_PKGS || true
fi

yes | pacman -Scc || true
