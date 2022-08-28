#!/bin/sh

# list of packages that will be installed
pkgs="alacritty neofetch zsh pkgfile fzf\
      awesome-git xorg feh ly betterlockscreen dunst picom-animations-git\
      bc wget xclip xf86-input-synaptics xf86-input-libinput xdotool xsel xkb-switch\
      alsa-utils pulseaudio pulseaudio-alsa\
      rofi flameshot\
      emacs neovim python-pip nodejs\
      lf-bin zoxide rm-improved bc ueberzug udiskie\
      librewolf-bin firefox tor-browser\
      nerd-fonts-source-code-pro ttf-iosevka-nerd ttf-roboto\
      brightnessctl\
      evince eog gpick font-manager\
      nextcloud-client libsecret gnome-keyring\
      exa bat sd ripgrep\
      unrar p7zip unzip\
      texlive-core texlive-bin texlive-latexextra texlive-langextra texlive-formatsextra texlive-fontsextra\
      texlive-humanities texlive-science texlive-publishers texlive-langcyrillic texlive-langgreek"

if [[ ! "$EUID" = 0 ]]; then
    sudo ls /root
fi

# install yay
if [[ ! -f $(which yay) ]]
then
    cd $(mktemp -d)
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg --noconfirm -scri
fi

# install the necessary packages
yay --noconfirm --needed -S $pkgs

if [[ ! -f $(which vcp) ]]
then
    cd $(mktemp -d)
    git clone https://github.com/none9632/VCP
    cd VCP
    make
    sudo make install
fi


