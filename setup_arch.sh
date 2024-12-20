#!/bin/zsh

source ./common_functions.sh
exported_log_function=$(typeset -f log_result)

SCRIPT_ORIGINAL_DIR=$(pwd)
read "username?What would you like your users name to be: "
read -s "password?Enter the desired password for $username:"
echo
read -s "confirm_pass?Confirm the password for $username:"
echo
if [[ "$password" != "$confirm_pass" ]];
then
	echo "Passwords do not match.Exiting."
	exit 1
fi

# Create user
useradd -m -g users -s /bin/zsh $username
echo "$username:$password" | chpasswd
usermod -aG wheel root
usermod -aG wheel $username
echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
log_result $? "setup_arch.sh" "Created user ${username} with sudo privileges" "Failed to create user ${username}"

# Run custom script that handles everything related to actual installation of packages
./install_pkgs.sh "$username"

# Enable NetworkManager to start on boot
systemctl enable NetworkManager
log_result $? "setup_arch.sh" "Enabled NetworkManager service" "Failed to enable NetworkManager service"

# Make sure NetworkManager is running
systemctl start NetworkManager
log_result $? "setup_arch.sh" "Started NetworkManager service" "Failed to start NetworkManager service"

# Install reflector with all default options
pacman -S --noconfirm reflector
log_result $? "setup_arch.sh" "Installed reflector package" "Failed to install reflector package"

# Backup mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
log_result $? "setup_arch.sh" "Backed up mirrorlist" "Failed to backup mirrorlist"

# Run reflector to get the best pacman mirrors
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
log_result $? "setup_arch.sh" "Ran reflector to get best pacman mirrors" "Failed to run reflector to get best pacman mirrors"

# Update and upgrade the system with all default options
pacman -Syyu --noconfirm
log_result $? "setup_arch.sh" "Updated and upgraded system" "Failed to update and/or upgrade system"

# Export default editor to be neovim
export EDITOR=nvim
log_result $? "setup_arch.sh" "Set EDITOR environment variable to neovim" "Failed to set EDITOR environment variable to neovim"

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
mkdir -p /home/$username/.local/share/applications
log_result $? "setup_arch.sh" "Create necessary directories" "Failed to create necessary directories"

cd /home/$username/Software

# Set grub theme to dracula
git clone https://github.com/dracula/grub.git grub-dracula
cp -r grub-dracula/dracula /boot/grub/themes
log_result $? "setup_arch.sh" "Set grub theme to dracula" "Failed to set grub theme to dracula"

# Update grub configuration to set the theme
if [ "$(grep -q '^GRUB_THEME=' /etc/default/grub && echo yes || echo no)" = "no" ]; then
    echo 'GRUB_THEME="/boot/grub/themes/dracula/theme.txt"' >> /etc/default/grub
else
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/dracula/theme.txt"|' /etc/default/grub
fi

# Regenerate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Download copyq dracula theme and copy it to themes directory
# copyq_themes_dir="$(copyq info themes)"
git clone https://github.com/dracula/copyq.git copyq-dracula $(copyq info themes)
# cp copyq-dracula/dracula.ini $(copyq info themes)
log_result $? "setup_arch.sh" "Downloaded and copied copyq dracula theme to copyq themes directory" "Failed to download and copy copyq theme to its theme directory"

# Set dunst theme to dracula
git clone https://github.com/dracula/dunst.git dunst-dracula /home/$username/.config/dunst
# cp dunst-dracula/dunstrc ~/.config/dunst/
log_result $? "setup_arch.sh" "Set dunst theme to dracula" "Failed to set dunst theme to dracula"

# Set GTK theme to dracula
git clone https://github.com/dracula/gtk.git /home/$username/.themes/gtk-master-dracula
log_result $? "setup-arch.sh:: Set GTK theme to dracula" "Failed to set GTK theme to dracula"

# Set icon theme to dracula
git clone https://github.com/dracula/gtk/files/5214870/Dracula.zip /home/$username/.icons/gtk-icons-dracula
log_result $? "setup_arch.sh" "Set icons theme to dracula" "Failed to set icons theme to dracula"

# Clone oh-my-zsh repository to user's home directory
HOME="/home/$username" ZSH="/home/$username/.oh-my-zsh" ZDOTDIR="/home/$username" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# SDDM configuration
cd $SCRIPT_ORIGINAL_DIR
systemctl enable sddm
log_result $? "setup_arch.sh" "Enabled sddm service" "Failed to enable sddm service"
log_result $? "setup_arch.sh" "Copied sddm config to its config directory" "Failed to copy sddm config to its config directory"
cp sddm/theme.conf /usr/share/sddm/themes/tokyo-night-sddm/theme.conf
log_result $? "setup_arch.sh" "Copied sddm theme to its theme directory" "Failed to copy sddm theme to its theme directory"

# Set global environment variables by appending to the /etc/environment file 
echo "PATH=$PATH:/home/$username/.bin" | sudo tee -a /etc/environment > /dev/null
log_result $? "setup_arch.sh" "Append user's .bin directory to PATH variable" "Failed to append user's .bin directory to PATH variable"

updatedb
log_result $? "setup_arch.sh" "Update db for file locating applications" "Failed to update db for file locating applications"

# Create pacman hook to clean cache after update, install, and remove operations
cp clean_package_cache.hook /etc/pacman.d/hooks/
mkdir -p /home/$username/.local/share/applications
cp remap_caps_esc.hook /etc/pacman.d/hooks/
log_result $? "setup_arch.sh" "Copy pacman hooks to the required directory" "Failed to copy pacman hooks to the required directory"

# Prepare ufw
systemctl enable ufw.service
log_result $? "setup_arch.sh" "Enable ufw service" "Failed to enable ufw service"
systemctl start ufw.service
log_result $? "setup_arch.sh" "Start ufw service" "Failed to start ufw service"
ufw enable
log_result $? "setup_arch.sh" "Enable ufw" "Failed to enable ufw"

# Enable ntp daemon to avoid time desynchronisation
systemctl enable ntpd.service
log_result $? "setup_arch.sh" "Enable ntpd service" "Failed to enable ntpd service"
systemctl start ntpd.service
log_result $? "setup_arch.sh" "Start ntpd service" "Failed to start ntpd service"

ufw allow http
log_result $? "setup_arch.sh" "Allow http in ufw" "Failed to allow http in ufw"
ufw allow https
log_result $? "setup_arch.sh" "Allow https in ufw" "Failed to allow https in ufw"
ufw allow www
log_result $? "setup_arch.sh" "Allow www in ufw" "Failed to allow www in ufw"

# Copy .desktop file used to run neovim within a new alacritty window to the local applications directroy
cp alacritty-nvim.desktop /home/$username/.local/share/applications/
log_result $? "setup_arch.sh" "Copy .desktop file used to run neovim within a new alacritty window to the local applications directory" "Failed to copy .desktop file used to run neovim within a new alacritty window to the local applications directory"

# Set some default apps by filetype
xdg-mime default feh.desktop image/png
log_result $? "setup_arch.sh" "Set feh as default image application (png)" "Failed to set feh as default image applicatin (png)"
xdg-mime default feh.desktop image/jpeg
log_result $? "setup_arch.sh" "Set feh as default image application (jpeg)" "Failed to set feh as default image applicatin (jpeg)"
xdg-mime default org.pwmt.zathura-pdf-poppler.desktop application/pdf
log_result $? "setup_arch.sh" "Set zathura as default pdf application" "Failed to set zathura as default pdf application"
xdg-mime default alacritty-nvim.desktop inode/x-empty
log_result $? "setup_arch.sh" "Set alacritty as default application for inode/empty files" "Failed to set alacritty as default application for inode/empty files"
xdg-mime default vlc.desktop audio/x-m4a
log_result $? "setup_arch.sh" "Set vlc as default audio application" "Set vlc as default audio application"

# Might need this to properly set keymap
# localectl set-x11-keymap gb

# Transfer ownership of user's home directory to them
chown -R $username:users /home/$username/

# Synchronise with dotfiles repository using chezmoi
su - "$username" <<EOF
	eval $exported_log_function
	cd /home/$username/
	log_result $? "Changed directory to user home ($(pwd))" "Failed to change directory to user home ($(pwd))"
	chezmoi init https://github.com/promitheas17j/dotfiles.git
	log_result $? "setup_arch.sh" "Initialised chezmoi repo" "Failed to initialise chezmoi repo"
	cd /home/"$username"/.local/share/chezmoi
	log_result $? "setup_arch.sh" "Changed directory to chezmoi directory" "Failed to change directory to chezmoi directory"
	git pull
	log_result $? "setup_arch.sh" "Pulled dotfiles from remote repo" "Failed to pull dotfiles from remote repo"
	chezmoi update -v
	log_result $? "setup_arch.sh" "Synched local dotfiles with chezmoi directory dotfiles" "Failed to synch local dotfiles with chezmoi directory dotfiles"
EOF

# Install treesitter cli to get rid of warning
npm install -g tree-sitter-cli

echo "If script finished without errors, do the following:"
echo "\t1) Go to copyq -> Preferences -> Appearance and load the dracula theme"
echo "\t2) Go to thunderbird -> Tools -> Add-ons and Themes and search for dracula then install it"
echo "\t3) Go to qbittorrent -> Tools -> Preferences -> Behaviour -> Interface -> Use custom UI Theme and select the dracula.qbtheme file"
echo "\t4) Open the file: /usr/share/dbus-1/services/org.xfce.xfce4-notityd.Notifications.service and change the line Name=org.freedesktop.Notifications to Name=org.freedesktop.NotificationsNone"
