#!/bin/zsh

SCRIPT_ORIGINAL_DIR=$(pwd)
read "username?What would you like your users name to be: "

# Create user
useradd -m -g users -s /bin/zsh $username
usermod -aG wheel root
usermod -aG wheel $username
echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "setup-arch.sh:: Created user ${username} with sudo privileges" >> setup_log.txt

# Run custom script that handles everything related to actual installation of packages
./install_pkgs.sh

# Enable NetworkManager to start on boot
systemctl enable NetworkManager
echo "setup-arch.sh:: Enabled NetworkManager service" >> setup_log.txt

# Make sure NetworkManager is running
systemctl start NetworkManager
echo "setup-arch.sh:: Started NetworkManager service" >> setup_log.txt

# Install reflector with all default options
pacman -S --noconfirm reflector
echo "setup-arch.sh:: Installed reflector package" >> setup_log.txt

# Backup mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo "setup-arch.sh:: Backed up mirrorlist" >> setup_log.txt

# Run reflector to get the best pacman mirrors
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo "setup-arch.sh:: Ran reflector to get best pacman mirrors" >> setup_log.txt

# Update and upgrade the system with all default options
pacman -Syyu --noconfirm
echo "setup-arch.sh:: Updated and upgraded system" >> setup_log.txt

# Export default editor to be neovim
export EDITOR=nvim
echo "setup-arch.sh:: Set EDITOR environment variable to neovim" >> setup_log.txt

# Make directories
mkdir /home/$username/Software # For software that needs files downloaded e.g. git cloning
mkdir /home/$username/themes
mkdir /home/$username/.icons
mkdir /home/$username/.bin
mkdir /home/$username/Documents
mkdir /home/$username/Pictures
mkdir /home/$username/Downloads
mkdir -p /mnt/usb_1/ /mnt/usb_2/ # Create directories for mountable media
mkdir -p /home/$username/.config/dunst
mkdir -p /etc/pacman.d/hooks
echo "setup-arch.sh:: Create necessary directories" >> setup_log.txt

cd /home/$username/Software

# Download and install yay
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si --noconfirm

# Set grub theme to dracula
git clone https://github.com/dracula/grub.git grub-dracula
cp -r grub-dracula/dracula /boot/grub/themes
echo "setup-arch.sh:: Set grub theme to dracula" >> setup_log.txt

# Download copyq dracula theme and copy it to themes directory
# copyq_themes_dir="$(copyq info themes)"
git clone https://github.com/dracula/copyq.git copyq-dracula $(copyq info themes)
# cp copyq-dracula/dracula.ini $(copyq info themes)
echo "setup-arch.sh:: Downloaded and copied copyq dracula theme to copyq themes directory" >> setup_log.txt

# Set dunst theme to dracula
git clone https://github.com/dracula/dunst.git dunst-dracula /home/$username/.config/dunst
# cp dunst-dracula/dunstrc ~/.config/dunst/
echo "setup-arch.sh:: Set dunst theme to dracula" >> setup_log.txt

# Set GTK theme to dracula
git clone https://github.com/dracula/gtk.git /home/$username/.themes/gtk-master-dracula
echo "setup-arch.sh:: Set GTK theme to dracula" >> setup_log.txt

# Set icon theme to dracula
git clone https://github.com/dracula/gtk/files/5214870/Dracula.zip /home/$username/.icons/gtk-icons-dracula
echo "setup-arch.sh:: Set icons theme to dracula" >> setup_log.txt

# SDDM configuration
cd $SCRIPT_ORIGINAL_DIR
systemctl enable sddm
cp sddm/sddm.conf /etc/sddm.conf
cp sddm/theme.conf /usr/share/sddm/themes/tokyo-night-sddm/theme.conf
echo "setup-arch.sh:: Enabled sddm service" >> setup_log.txt
echo "setup-arch.sh:: Copied sddm config to its config directory" >> setup_log.txt
echo "setup-arch.sh:: Copied sddm theme to its theme directory" >> setup_log.txt

# Set global environment variables by appending to the /etc/environment file 
echo "PATH=$PATH:/home/$username/.bin" | sudo tee -a /etc/environment > /dev/null
echo "setup-arch.sh:: Append user's .bin directory to PATH variable" >> setup_log.txt

updatedb
echo "setup-arch.sh:: Update db for file locating programs" >> setup_log.txt

# Create pacman hook to clean cache after update, install, and remove operations
cp clean_package_cache.hook /etc/pacman.d/hooks/
cp remap_caps_esc.hook /etc/pacman.d/hooks/
echo "setup-arch.sh:: Copy pacman hooks to the required directory" >> setup_log.txt

# Prepare ufw
systemctl enable ufw.service
systemctl start ufw.service
ufw enable
echo "setup-arch.sh:: Enable ufw service" >> setup_log.txt
echo "setup-arch.sh:: Start ufw service" >> setup_log.txt
echo "setup-arch.sh:: Enable ufw" >> setup_log.txt

# Enable ntp daemon to avoid time desynchronisation
systemctl enable ntpd.service
systemctl start ntpd.service
echo "setup-arch.sh:: Enable ntpd service" >> setup_log.txt
echo "setup-arch.sh:: Start ntpd service" >> setup_log.txt

ufw allow http
ufw allow https
ufw allow www
echo "setup-arch.sh:: Allow http in ufw" >> setup_log.txt
echo "setup-arch.sh:: Allow https in ufw" >> setup_log.txt
echo "setup-arch.sh:: Allow www in ufw" >> setup_log.txt

# Copy .desktop file used to run neovim within a new alacritty window to the local applications directroy
cp alacritty-nvim.desktop /home/$username/.local/share/applications/
echo "setup-arch.sh:: Copy .desktop file used to run neovim within a new alacritty windowto the local applications directory" >> setup_log.txt

# Set some default apps by filetype
xdg-mime default feh.desktop image/png
xdg-mime default feh.desktop image/jpeg
xdg-mime default org.pwmt.zathura-pdf-poppler.desktop application/pdf
xdg-mime default alacritty-nvim.desktop inode/x-empty
xdg-mime default vlc.desktop audio/x-m4a
echo "setup-arch.sh:: Set feh as default image application (png,jpg)" >> setup_log.txt
echo "setup-arch.sh:: Set zathura as default pdf application" >> setup_log.txt
echo "setup-arch.sh:: Set alacritty as default application for inode/empty files" >> setup_log.txt
echo "setup-arch.sh:: Set vlc as default audio application" >> setup_log.txt

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
