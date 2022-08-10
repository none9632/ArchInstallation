#!/bin/sh

# My personal system configuration

# sudo configuration
echo "$(whoami) myPC= NOPASSWD: /usr/bin/yay -Syy,/usr/bin/pacman -Sql" |
    sudo tee -a /etc/sudoers

# pacman configuration
sudo sed -i -e 's/#Color/Color/g' /etc/pacman.conf
sudo sed -i -e 's/#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
sudo sed -i -e 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

# My own configuration
folders="$HOME/Projects $HOME/Pictures $HOME/Downloads"
mkdir $folders
git clone https://github.com/none9632/mydotfiles $HOME/Projects/mydotfiles
git clone https://github.com/none9632/.emacs.d $HOME/.emacs.d

# setting display manager
sudo systemctl enable ly

# betterlockscreen
echo "[Unit]
Description = Lock screen when going to sleep/suspend
Before=sleep.target
Before=suspend.target

[Service]
User=%i
Type=simple
Environment=DISPLAY=:0
ExecStart=/usr/bin/betterlockscreen --lock
TimeoutSec=infinity
ExecStartPost=/usr/bin/sleep 1
ExecStartPre=/usr/bin/xkb-switch -s us

[Install]
WantedBy=sleep.target
WantedBy=suspend.target" | sudo tee /etc/systemd/system/betterlockscreen@.service
sudo systemctl enable betterlockscreen@$(whoami).service

# gnome-keyring
echo "auth       optional     pam_gnome_keyring.so
session    optional     pam_gnome_keyring.so auto_start" | sudo tee -a /etc/pam.d/login

# zsh
if [ "$(ls /var/cache/pkgfile)" == "" ]
then
    sudo pkgfile --update
fi

# neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
pip install pynvim

# git configuration
git config --global user.email "none9632@protonmail.com"
git config --global user.name "none9632"
git config --global credential.helper store

# Touchpad configuration
mkdir -p /etc/X11/xorg.conf.d
echo "Section \"InputClass\"
    Identifier \"devname\"
    Driver \"libinput\"
    MatchIsTouchpad \"on\"
        Option \"Tapping\" \"on\"
        Option \"HorizontalScrolling\" \"on\"
        Option \"TappingButtonMap\" \"lrm\"
EndSection" | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf

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
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/touchpadfix.service
sudo systemctl enable touchpadfix.service

# changed default browser
mimeapps_dir="$HOME/.local/share/applications"
mimeapps_file="$mimeapps_dir/mimeapps.list"
if [[ ! -s $mimeapps_file ]]
then
    mkdir -p $mimeapps_dir
    touch $mimeapps_file
    echo "[Default Applications]" > $mimeapps_file
    echo "x-scheme-handler/http=librewolf.desktop" >> $mimeapps_file
    echo "x-scheme-handler/https=librewolf.desktop" >> $mimeapps_file
fi

