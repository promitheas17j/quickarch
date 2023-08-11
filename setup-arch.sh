#!/bin/sh

PACMAN_PKGS=(
	'zsh'
	'mesa'
	'sddm'
	'xorg-server'
	'xorg-apps'
	'xorg-xinit'
	'xf86-video-amdgpu'
	'neovim'
	'bspwm'
	'sxhkd'
	'wpa_supplicant'
	'bluez'
	'bluez-utils'
	'git'
	'chezmoi'
	'alacritty'
	'openssh'
	'man-db'
	'man-pages'
	'polybar'
	'alsa-utils'
	'pulseaudio'
	'vlc'
	'ssh-keygen'
	'yay'
	'rofi'
	'lsof'
	'qbittorrent'
	'copyq'
	'thunar'
	'thunderbird'
	'zip'
	'unzip'
	'sddm'
	'qt5-quickcontrols2'
	'qt5-graphicaleffects'
	'qt5-svg'
	'flameshot'
	'htop'
	'fd'
	'xfce4-power-manager'
	'discord'
)	

AUR_PKGS=(
	'brave-bin'
	'pavucontrol'
	'stremio'
	'anydesk-bin'
	'sddm-theme-tokyo-night'
	'unixbench'
	'beeper'
	'netflix'
)

# Enable NetworkManager to start on boot
systemctl enable NetworkManager

# Make NetworkManager is running
systemctl start NetworkManager

# Install reflector with all default options
pacman -S --noconfirm reflector

# Backup mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# Run reflector to get the best pacman mirrors
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Update and upgrade the system with all default options
pacman -Syyu --noconfirm

# Export default editor to be neovim
export EDITOR=nvim

# Installing packages
for PKG in "${PACMAN_PKGS[@]}";
do
	echo "Installing: ${PKG}"
	pacman -S "$PKG" --noconfirm --needed
done

# Create user
useradd -m -g users -s /bin/zsh mart
usermod -aG wheel root
usermod -aG wheel mart

# Make directory for software installations requiring file to be downloaded
mkdir /home/mart/Software
cd /home/mart/Software

# Download and install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# Installing packages from AUR
for PKG in "${PACMAN_PKGS[@]}";
do
	echo "[AUR] Installing: ${PKG}"
	yay -S "$PKG" --noconfirm --needed
done

# General 'housecleaning' stuff
mkdir -p /home/mart/Documents
mkdir -p /home/mart/Pictures
mkdir -p /home/mart/Downloads

# Create a couple directories for mounting usb's
mkdir -p /mnt/usb_1/ /mnt/usb_2/

# SDDM configuration
systemctl enable sddm
cp sddm/sddm.conf /etc/sddm.conf
cp sddm/theme.conf /usr/share/sddm/themes/tokyo-night-sddm/theme.conf

# Synchronise with dotfiles repository using chezmoi
# WILL LIKELY BREAK AS GITHUB AUTH NOT SET UP YET AT THIS POINT
# chezmoi init https://github.com/promitheas17j/dotfiles.git
# cd /home/mart/.local/share/chezmoi
# git pull
# chezmoi update -v
