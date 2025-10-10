#!/bin/zsh

source ./common_functions.sh
exported_log_function=$(typeset -f log_result)

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
	'vlc-plugin-ffmpeg'
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
	'pacman-contrib'
	'xdotool'
	'xclip'
	'homebank'
	'dunst'
	'picom'
	'hexchat'
	'zathura'
	'zathura-pdf-poppler'
	'ufw'
	'gimp'
	'inkscape'
	'vulkan-radeon'
	'ntp'
	'valgrind'
	'fzf'
	'tree'
	'pandoc'
	'noto-fonts'
	'noto-fonts-emoji'
	'network-manager-applet'
	'libreoffice-still'
	'ntp'
	'xdo'
	'at'
	'x11-ssh-askpass'
	'amfora'
)

AUR_PKGS=(
	'brave-bin'
	'pavucontrol'
	'stremio'
	'anydesk-bin'
	'sddm-theme-tokyo-night'
	'unixbench'
	'beeper-latest-bin'
	'dracula-cursors-git'
	'lf'
	'nerd-fonts-meta'
	'spotify'
	'ledger-live-bin'
	'passy'
	'rar'
	'ctpv-git'
	'betterlockscreen'
	'zenmap'
	'ttf-cascadia-code-nerd'
	'sddm-theme-tokyo-night-git'
	'nvim-packer-git'
	'tree-sitter-cli'
	'criterion'
	'docker'
)

OPTIONAL_PACMAN_PACKAGES=(
	'texlive'
)

GAMING_PACKAGES=(
	'steam'
	'lutris'
	'bottles'
	'gamemode'
)

username="$1"
choice_optional_pkgs='z'
echo "Optional Packages:"
for PKG in "${OPTIONAL_PACMAN_PACKAGES}";
do
	echo "${PKG}"
done

while [[ ${choice_optional_pkgs} != 'y' && ${choice_optional_pkgs} != 'Y' &&  ${choice_optional_pkgs} != 'n' && ${choice_optional_pkgs} != 'N' ]];
do
	read "choice_optional_pkgs?Would you like to install optional packages? [yY/nN]"
done
echo "$(date '+%Y-%m-%d%H:%M:%S') install_pkgs.sh - Install optional packages: ${choice_optional_pkgs}" >> quickarch_logs.txt

choice_gaming_pkgs='z'
echo
echo
echo "Gaming Packages:"
for PKG in "${GAMING_PACKAGES}";
do
	echo "${PKG}"
done

while [[ ${choice_gaming_pkgs} != 'y' && ${choice_gaming_pkgs} != 'Y' &&  ${choice_gaming_pkgs} != 'n' && ${choice_gaming_pkgs} != 'N' ]];
do
	read "choice_gaming_pkgs?Would you like to install gaming packages? [yY/nN]"
done
echo "$(date '+%Y-%m-%d%H:%M:%S') install_pkgs.sh - Install gaming packages: ${choice_gaming_pkgs}" >> quickarch_logs.txt

# Installing packages
# Switch into non-root user to install yay
su - "${username}" <<EOF
	eval $exported_log_function
	git clone https://aur.archlinux.org/yay.git ~/yay
	log_result $? "install_pkgs.sh" "Cloned yay repository" "Failed to clone yay repository"
	cd ~/yay
	log_result $? "install_pkgs.sh" "Changed directory to yay directory" "Failed to change directory to yay repository"
	makepkg -si --noconfirm
	log_result $? "install_pkgs.sh" "Built and installed yay" "Failed to build and install yay"
	cd ~
	rm -r ~/yay
	log_result $? "install_pkgs.sh" "Cleaned up yay installation directory" "Failed to cleanup yay installation directory"
EOF

for PKG in "${PACMAN_PKGS[@]}";
do
	echo "Installing: ${PKG}"
	pacman -S "$PKG" --noconfirm --needed
	log_result $? "install_pkgs.sh" "Installed pacman package: ${PKG}" "Failed to install pacman package: ${PKG}"
done

# Installing packages from AUR
for PKG in "${AUR_PKGS[@]}";
do
	echo "[AUR] Installing: ${PKG}"
	yay -S "$PKG" --noconfirm --needed --mflags "--skipinteg"
	log_result $? "install_pkgs.sh" "Installed AUR package: ${PKG}" "Failed to install AUR package: ${PKG}"
done

# Only install the optional packages if user wants to
if [[ "${choice_optional_pkgs}" = 'y' || "${choice_optional_pkgs}" = 'Y']]
then
	for PKG in "${OPTIONAL_PACMAN_PACKAGES[@]}";
	do
		echo "Installing optional package: ${PKG}"
		yay -S "${PKG}" --noconfirm --needed --mflags "--skipinteg"
		log_result $? "install_pkgs.sh" "Installed optional package: ${PKG}" "Failed to install optional package: ${PKG}"
	done
fi

# Only install the gaming packages if user wants to
if [[ "${choice_gaming_pkgs}" = 'y' || "${choice_gaming_pkgs}" = 'Y']]
then
	for PKG in "${GAMING_PACKAGES[@]}";
	do
		echo "Installing gaming package: ${PKG}"
		yay -S "${PKG}" --noconfirm --needed --mflags "--skipinteg"
		log_result $? "install_pkgs.sh" "Installed gaming package: ${PKG}" "Failed to install gaming package: ${PKG}"
	done
fi
