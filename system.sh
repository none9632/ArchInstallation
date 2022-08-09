#!/bin/sh

# My personal system configuration

# list of packages that will be installed
pkgs="alacritty neofetch zsh pkgfile fzf\
      awesome-git xorg feh ly betterlockscreen dunst picom-animations-git\
      bc wget xclip xf86-input-synaptics xf86-input-libinput xdotool xsel xkb-switch\
      alsa-utils pulseaudio pulseaudio-alsa\
      rofi flameshot\
      emacs neovim pip nodejs\
      lf-bin zoxide rm-improved bc ueberzug udiskie\
      librewolf-bin firefox tor-browser\
      nerd-fonts-source-code-pro ttf-iosevka-nerd ttf-roboto\
      brightnessctl\
      evince eog gpick font-manager\
      nextcloud-client libsecret gnome-keyring\
      exa bat\
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

# browser configuration
if [ -e $HOME/.librewolf ] && [ -e $HOME/.mozilla ]
then
    librewolf_dir=$HOME/.librewolf
    librewolf_extensions_dir=$librewolf_dir/$(ls $HOME/.librewolf | grep -E *-release)/extensions
    firefox_dir=$HOME/.mozilla/firefox
    firefox_extensions_dir=$firefox_dir/$(ls $HOME/.mozilla/firefox | grep -E *-release)/extensions
    links="https://addons.mozilla.org/firefox/downloads/file/3961087/ublock_origin-1.43.0.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3965972/vimium_c-1.98.3.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3910598/canvasblocker-1.8.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3902154/decentraleyes-2.0.17.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3971429/cookie_autodelete-3.8.1.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3965730/i_dont_care_about_cookies-3.4.1.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3872283/privacy_badger17-2021.11.23.1.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3968598/duckduckgo_for_firefox-2022.6.27.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3954910/noscript-11.4.6.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3790944/dont_track_me_google1-4.26.xpi\
            https://addons.mozilla.org/firefox/downloads/file/3980848/clearurls-1.25.0.xpi"

    mkdir -p $librewolf_extensions_dir $firefox_extensions_dir

    for link in $links
    do
        dir=$(mktemp -d)
        file=$(echo $link | awk 'BEGIN{FS="/"} {print $NF}')

        echo -n "Installing $file..."
        cd $dir
        wget -q $link
        unzip -q ./$file -d $dir

        if [ -e $dir/mozilla-recommendation.json ]
        then
            addon_id=$(egrep -o 'addon_id":"[^"]+' ./mozilla-recommendation.json | awk 'BEGIN{FS="\""} {print $NF}')
        else
            addon_id=$(egrep -o 'id":[\ ]+"[^"]+' ./manifest.json | awk 'BEGIN{FS="\""} {print $NF}')
        fi
        if [ "$addon_id" != "" ]
        then
            cp $dir/$file $librewolf_extensions_dir/${addon_id}.xpi
            cp $dir/$file $firefox_extensions_dir/${addon_id}.xpi
            echo "done"
        else
            echo "error"
        fi
    done

    echo "defaultPref("browser.sessionstore.resume_from_crash", false);
defaultPref("network.cookie.lifetimePolicy", 0);
defaultPref("privacy.resistFingerprinting", false);
defaultPref("privacy.clearOnShutdown.cookies", false);" > $librewolf_dir/librewolf.overrides.cfg
fi

