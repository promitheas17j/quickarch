#!/bin/sh

# Enable NetworkManager to start on boot
systemctl enable NetworkManager
# Make NetworkManager is running
systemctl start NetworkManager
# Create a couple directories for mounting usb's
mkdir -p /mnt/usb_1/ /mnt/usb_2/
# Install reflector with all default options
pacman -S --noconfirm reflector
# Backup mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
# Run reflector to get the best pacman mirrors
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
# Update and upgrade the system with all default options
pacman -Syyu --noconfirm

# Installing packages
pacman -S zsh mesa sddm xorg-server xorg-apps xorg-xinit xf86-video-amdgpu neovim bspwm sxhkd wpa_supplicant bluez bluez-utils git chezmoi alacritty openssh man-db man-pages polybar rofi alsa-utils pulseaudio vlc --noconfirm --needed

# Export default editor to be neovim
export EDITOR=nvim

# Add user
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
yay -S brave-bin pavucontrol anamnesis
