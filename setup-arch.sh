#!/bin/sh

SCRIPT_ORIGINAL_DIR=$(pwd)
read "username?What would you like your users name to be: "

# Run custom script that handles everything related to actual installation of packages
./install_pkgs.sh

# Enable NetworkManager to start on boot
systemctl enable NetworkManager

# Make sure NetworkManager is running
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

# Create user
useradd -m -g users -s /bin/zsh $username
usermod -aG wheel root
usermod -aG wheel $username

# Make directories
mkdir /home/$username/Software # For software that needs files downloaded e.g. git cloning
mkdir ~/.themes
mkdir ~/.icons
mkdir -p /home/$username/Documents
mkdir -p /home/$username/Pictures
mkdir -p /home/$username/Downloads
mkdir -p /mnt/usb_1/ /mnt/usb_2/ # Create directories for mountable media

cd /home/$username/Software

# Download and install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# Set grub theme to dracula
git clone https://github.com/dracula/grub.git grub-dracula
cp -r grub-dracula/dracula /boot/grub/themes

# Download copyq dracula theme and copy it to themes directory
copyq_themes_dir="$(copyq info themes)"
git clone https://github.com/dracula/copyq.git copyq-dracula
cp copyq-dracula/dracula.ini $copyq_themes_dir

# Set dunst theme to dracula
git clone https://github.com/dracula/dunst.git dunst-dracula
mkdir -p ~/.config/dunst
cp dunst-dracula/dunstrc ~/.config/dunst/

# Set GTK theme to dracula
git clone https://github.com/dracula/gtk.git ~/.themes/gtk-master-dracula

# Set icon theme to dracula
git clone https://github.com/dracula/gtk/files/5214870/Dracula.zip ~/.icons/gtk-icons-dracula

# SDDM configuration
cd $SCRIPT_ORIGINAL_DIR
systemctl enable sddm
cp sddm/sddm.conf /etc/sddm.conf
cp sddm/theme.conf /usr/share/sddm/themes/tokyo-night-sddm/theme.conf

updatedb

# Create pacman hook to clean cache after update, install, and remove operations
mkdir -p /etc/pacman.d/hooks
cp clean_package_cache.hook /etc/pacman.d/hooks/

# Prepare ufw
systemctl enable ufw.service
systemctl start ufw.service
ufw enable

# Enable ntp daemon to avoid time desynchronisation
systemctl enable ntpd.service
systemctl start ntpd.service

# KDEConnect firewall settings
ufw allow 1714:1764/udp
ufw allow 1714:1764/tcp
ufw reload

ufw allow http
ufw allow https
ufw allow www

# Copy .desktop file used to run neovim within a new alacritty window to the local applications directroy

cp alacritty-nvim.desktop /home/$username/.local/share/applications/
# Set some default apps by filetype
xdg-mime default feh.desktop image/png
xdg-mime default feh.desktop image/jpeg
xdg-mime default org.pwmt.zathura-pdf-poppler.desktop application/pdf
xdg-mime default alacritty-nvim.desktop inode/x-empty

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
echo "\t7) Open the file: /usr/share/dbus-1/services/org.xfce.xfce4-notityd.Notifications.service and change the line Name=org.freedesktop.Notifications to Name=org.freedesktop.NotificationsNone"
