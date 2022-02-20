#!/bin/bash
# updade and upgrade.
sudo apt update
sudo apt upgrade -y

# rename directory to ENG.
env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update

# Ctrl + Alt + Backspace to kill X server.
sudo dpkg-reconfigure keyboard-configuration

# Icon settings.
gsettings set org.gnome.gedit.preferences.encodings auto-detected "['UTF-8','CURRENT','SHIFT_JIS','EUC-JP','ISO-2022-JP','UTF-16']"
gsettings set org.gnome.gedit.preferences.encodings shown-in-menu "['UTF-8','SHIFT_JIS','EUC-JP','ISO-2022-JP','UTF-16']"
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
gsettings set org.gnome.shell.extensions.desktop-icons show-home false
gsettings set org.gnome.mutter auto-maximize false

# remove Gmail/Amazon/Twitter/Facebook
sudo apt remove -y unity-webapps-common xul-ext-unity xul-ext-websites-integration

# disable updatedb.
sudo chmod 644 /etc/cron.daily/mlocate

# software.
sudo apt install -y linux-headers-$(uname -r)
sudo apt install -y dkms build-essential module-assistant manpages-ja manpages-ja-dev
sudo apt install -y tree curl whois git vim terminator gufw htop net-tools
sudo apt install -y python3 python3-dev python3-pip
sudo apt install -y nmap traceroute tor proxychains

# Hack nerd font.
mkdir ~/.fonts
wget -O ~/Downloads/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
unzip ~/Downloads/Hack.zip -d ~/.fonts/
rm -f ~/Downloads/Hack.zip

# HackGen nerd font.
wget -O ~/Downloads/HackGenNerd.zip https://github.com/yuru7/HackGen/releases/download/v2.5.3/HackGenNerd_v2.5.3.zip
unzip ~/Downloads/HackGenNerd.zip -d ~/.fonts/
rm -f ~/Downloads/HackGenNerd.zip

sudo fc-cache -f -v

# Vundle.
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# papirus icon.
sudo add-apt-repository ppa:papirus/papirus
sudo apt update
sudo apt install papirus-icon-theme

# Fish.
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install -y fish
chsh -s $(which fish)

# OMF.
git clone https://github.com/oh-my-fish/oh-my-fish
cd oh-my-fish
bin/install --offline
echo "omf install kawasaki" | fish

# dot.
mkdir ~/.config/terminator
git clone https://github.com/ar0f/dot.git
cp ./dot/vimrc ~/.vimrc
cp ./dot/config.fish ~/.config/fish/config.fish
cp ./dot/config.terminator ~/.config/terminator/config

# clean up.
sudo apt clean
sudo apt autoremove
sudo rm /var/crash/*
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport
cd /var/tmp/
sudo dd if=/dev/zero of=./EMPTY bs=1M
sudo rm ./EMPTY