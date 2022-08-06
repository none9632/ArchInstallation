#!/bin/sh

# Set the time zone
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
# Set the Hardware Clock from the System Clock and update the timestamps in /etc/adjtime
hwclock --systohc

sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i -e 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "myPC" > /etc/hostname
echo '127.0.0.1 localhost
::1 localhost
127.0.1.1   myPC.localdomain   myPC' >> /etc/hosts

echo 'Set root password'
passwd
read -p "Enter username: " name
useradd -m $name
echo "Set password for $name"
passwd $name
usermod -aG wheel,audio,video,optical,storage $name

# sudo configuration
sed -i -e 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
echo "$name myPC= NOPASSWD: /usr/bin/yay -Syy,/usr/bin/pacman -Sql" >> /etc/sudoers
# pacman configuration
sed -i -e 's/#Color/Color/g' /etc/pacman.conf
sed -i -e 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

# Touchpad configuration
echo "Section "InputClass"
    Identifier "devname"
    Driver "libinput"
    MatchIsTouchpad "on"
        Option "Tapping" "on"
        Option "HorizontalScrolling" "on"
        Option "TappingButtonMap" "lrm"
EndSection" > /etc/X11/xorg.conf.d/40-libinput.conf

# Touchpad fix for my laptop (https://bbs.archlinux.org/viewtopic.php?id=263407)
echo "[Unit]
Description=I hope hope hope this works
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service systemd-logind.service

[Service]
ExecStart=/usr/bin/bash -c '\
  /usr/bin/modprobe -r i2c_hid; \
  /usr/bin/modprobe i2c_hid'

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/touchpadfix.service
systemctl enable touchpadfix.service

# network configuration
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable dhcpcd
ip route add default via 192.168.1.1 dev wlan0

# My own configuration
folders="/home/$name/Projects /home/$name/Pictures /home/$name/Downloads"
mkdir $folders
git clone https://github.com/none9632/mydotfiles /home/$name/Projects/mydotfiles
git clone https://github.com/none9632/.emacs.d /home/$name/.emacs.d
chown -R $name $folders /home/$name/.emacs.d
chgrp -R $name $folders /home/$name/.emacs.d

# git configuration
git config --global user.email "none9632@protonmail.com"
git config --global user.name "none9632"

# grub-install --target=i386-pc /dev/sda
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
