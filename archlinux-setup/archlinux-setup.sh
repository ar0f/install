#!/bin/bash
#
#SYSTEM INSTALL NOTE(ez way):
#loadkeys jp106
#curl -sL https://raw.githubusercontent.com/picodotdev/alis/master/download.sh | bash
#curl -O https://raw.githubusercontent.com/ar0f/install/main/alis.conf
#./alis.sh

##################################################
# check root. for makepkg command.
if [ ${EUID:-${UID}} = 0 ]; then
	echo 'Do not run as ROOT.'
	exit 1
fi

echo -e "\n[+] SETUP INITIATING...\n\n"

# Logging
#exec 2>> stderr.log 1> >(tee -a stdout.log)


##################################################
ABS_PATH=$(cd $(dirname ${0}) && pwd)
SKIP_ASK="--noconfirm --needed" # Pacman skip confirm in install.
COUNTRY="Japan"
KEYMAP="jp106"
KEY="jp"


###################### INIT ######################
# makepkg: Parallel compil
echo -e "[+] set MAKEFLAGS = $(nproc) >> /etc/makepkg.conf"
echo -e "\nMAKEFLAGS=\"-j $(nproc)\"" | sudo tee -a /etc/makepkg.conf

# Set keyboard
localectl set-keymap --no-convert $KEYMAP
localectl set-x11-keymap $KEY
sudo setxkbmap $KEY

# pacman setup
sudo pacman -Syy
sudo pacman -S reflector $SKIP_ASK
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig.bak
sudo reflector --country $COUNTRY --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy

# Common
sudo pacman -Syu $SKIP_ASK
sudo pacman -S base-devel vi vim wget git unzip $SKIP_ASK
sudo pacman -S rxvt-unicode $SKIP_ASK

# man
sudo pacman -S man $SKIP_ASK
# update manually
mandb

# Yay
#git clone https://aur.archlinux.org/yay.git
#cd yay
#makepkg -si $SKIP_ASK
#rm -rf yay
#cd ..
#yay -Syu $SKIP_ASK

# Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si $SKIP_ASK
cd ..
rm -rf paru
paru

# English Directory
# [WARNING!] all home directories have been deleted.
readlink -f $HOME/* | sed -e 's!'$ABS_PATH'!!g' | sed '/^$/d' | xargs -n 1 rm -rf
sudo pacman -S xdg-user-dirs $SKIP_ASK
LC_ALL=C xdg-user-dirs-update --force

# i3 Setup
#alise.sh: i3-gaps i3blocks i3lock i3status dmenu rxvt-unicode lightdm lightdm-gtk-greeter xorg-server
sudo pacman -S xorg-xinit xorg-xrdb $SKIP_ASK
sudo pacman -Rs i3blocks dmenu $SKIP_ASK


###################### COMMON SYSTEM ######################
# Setting Tool
sudo pacman -S lxappearance $SKIP_ASK

# FireWall Setting tool
sudo pacman -S ufw $SKIP_ASK

# OpenSSH Server
sudo pacman -S openssh $SKIP_ASK


###################### HARDWARE ######################
# Network
sudo pacman -S networkmanager network-manager-applet gnome-keyring wpa_supplicant dialog $SKIP_ASK

# Sound
sudo pacman -S alsa-utils $SKIP_ASK

# Power
sudo pacman -S xfce4-power-manager $SKIP_ASK


###################### COMMON SOFTWARE ######################
# Filer
sudo pacman -S thunar $SKIP_ASK

# Browser
sudo pacman -S firefox $SKIP_ASK
paru -S google-chrome $SKIP_ASK

# Editor
sudo pacman -S leafpad $SKIP_ASK

# Input method
sudo pacman -S fcitx fcitx-mozc fcitx-configtool $SKIP_ASK

# Visual Studio Code
sudo pacman -S code $SKIP_ASK

# GIMP (GNU Image Manipulation Program)
sudo pacman -S gimp $SKIP_ASK

# Notification deamon
sudo pacman -S dunst $SKIP_ASK

# htop
sudo pacman -S htop $SKIP_ASK

# Neofetch
sudo pacman -S neofetch $SKIP_ASK


###############################################################
# cache clear
yes | sudo pacman -Scc


###################### ADVANCED SOFTWARE ######################
# Nmap: port scanner
sudo pacman -S nmap $SKIP_ASK

# rkhunter: rootkit scanner
sudo pacman -S rkhunter $SKIP_ASK
sudo rkhunter --update

# Wireshark: packet capture
sudo pacman -S wireshark-qt $SKIP_ASK
sudo usermod -a -G wireshark $USER
sudo chmod +x /usr/bin/dumpcap

# iftop: network monitor
sudo pacman -S iftop $SKIP_ASK


###################### THEME ######################
# GTK Theme
sudo pacman -S arc-gtk-theme $SKIP_ASK

# Transparency
sudo pacman -S compton $SKIP_ASK

# Font
sudo pacman -S ttf-dejavu ttf-font-awesome awesome-terminal-fonts otf-ipafont otf-ipaexfont $SKIP_ASK
paru -S ttf-hackgen-nerd nerd-fonts-hack $SKIP_ASK
sudo fc-cache -f -v

# Cursors
sudo pacman -S capitaine-cursors $SKIP_ASK

# Icon
sudo pacman -S papirus-icon-theme $SKIP_ASK

# Polybar
paru -S polybar $SKIP_ASK

# Nitrogen
sudo pacman -S nitrogen $SKIP_ASK

# Rofi
sudo pacman -S rofi $SKIP_ASK

# Lightdm theme
paru -S lightdm-webkit2-greeter $SKIP_ASK
paru -S lightdm-webkit2-theme-sapphire $SKIP_ASK
sudo sed -i -e "s/#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/g" /etc/lightdm/lightdm.conf
sudo sed -i -e "s/antergos/lightdm-theme-sapphire/g" /etc/lightdm/lightdm-webkit2-greeter.conf

# Plank is not recommended on i3-wm.
#sudo pcaman -S plank plank-theme-glossient $SKIP_ASK


###################### SYSTEM SETUP ######################
sudo mkdir -p /mnt/cdrom

# [man-db.service --quiet] disable. reason: boot is slow.
sudo systemctl disable man-db

# Service enable
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager
sudo systemctl enable sshd
sudo systemctl enable ufw


###################### THEME SETUP ######################
# Copy font
FONT_DIR="$HOME/.local/share/fonts"
if [[ -d $FONT_DIR ]]; then
	cp -rf $ABS_PATH/fonts/* $FONT_DIR
else
	mkdir -p $FONT_DIR
	cp -rf $ABS_PATH/fonts/* $FONT_DIR
fi
sudo fc-cache -f -v

# Copy GTK3.0 settings.ini
cp -rf $ABS_PATH/gtk-3.0 $HOME/
sudo ln -s $HOME/.config/gtk-3.0/settings.ini /etc/gtk-3.0/settings.ini

# Copy .xprofile
cp -f $ABS_PATH/.xprofile $HOME/

# Copy .Xresources
cp -f $ABS_PATH/.Xresources $HOME/
xrdb -merge $HOME/.Xresources

# Copy start urxvt deamon script.
sudo cp $ABS_PATH/run_urxvt /usr/local/bin/
sudo chmod +x /usr/local/bin/run_urxvt

# Copy .config
cp -rf $ABS_PATH/i3_config/* $HOME/.config/

chmod +x $HOME/.config/**.sh
chmod +x $HOME/.config/rofi/bin/*


###################### CLEAR ######################
# Clean up
yes | sudo pacman -Scc
yes | sudo pacman -Rs $(pacman -Qdtq)
yes | paru -Scc
sudo rm -rf /var/cache/**
sudo rm -rf $HOME/.cache/**

echo -e "\n\n[x] ALL DONE. REBOOTING...\n\n"
sleep 10s

# reboot
systemctl reboot