#!/bin/sh

SCRIPT_ORIGINAL_DIR=$(pwd)

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
	'feh'
	'ripgrep'
	'mlocate'
	'neofetch'
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
	'dracula-cursors-git'
	'lf'
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

# Set grub theme to dracula
cd ~/Software
git clone https://github.com/dracula/grub.git grub-dracula
cp -r grub-dracula/dracula /boot/grub/themes

# Download copyq dracula theme and copy it to themes directory
copyq_themes_dir="$(copyq info themes)"
git clone https://github.com/dracula/copyq.git copyq-dracula
cp copyq-dracula/dracula.ini $copyq_themes_dir

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
cd $SCRIPT_ORIGINAL_DIR
systemctl enable sddm
cp sddm/sddm.conf /etc/sddm.conf
cp sddm/theme.conf /usr/share/sddm/themes/tokyo-night-sddm/theme.conf

updatedb

# Might need this to properly set keymap
# localectl set-x11-keymap gb

# Synchronise with dotfiles repository using chezmoi
# WILL LIKELY BREAK AS GITHUB AUTH NOT SET UP YET AT THIS POINT
# chezmoi init https://github.com/promitheas17j/dotfiles.git
# cd /home/mart/.local/share/chezmoi
# git pull
# chezmoi update -v
#

echo "If script finished without errors, do the following:"
echo "\t1) Run: sudo nvim /etc/default/grub"
echo "\t2) Set: GRUB_THEME to '/boot/grub/themes/dracula.theme.txt'"
echo "\t3) Run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo "\t4) Go to copyq -> Preferences -> Appearance and load the dracula theme"
echo "\t5) Go to thunderbird -> Tools -> Add-ons and Themes and search for dracula then install it"
echo "\t6) Go to qbittorrent -> Tools -> Preferences -> Behaviour -> Interface -> Use custom UI Theme and select the dracula.qbtheme file"
