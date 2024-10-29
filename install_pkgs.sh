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
	'feh'
	'ripgrep'
	'mlocate'
	'neofetch'
	'pacman-contrib'
	'xdotool'
	'lxappearance'
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
	'lib32-vulkan-radeon'
	'ntp'
	'valgrind'
	'fzf'
	'tree'
	'pandoc'
)

AUR_PKGS=(
	'brave-bin'
	'pavucontrol'
	'stremio'
	'anydesk-bin'
	'sddm-theme-tokyo-night'
	'unixbench'
	'beeper-latest-bin'
	'netflix'
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
)

OPTIONAL_PACMAN_PACKAGES=(
	'qemu-full'
	'qemu-emulators-full'
	'texlive-full'
)

GAMING_PACKAGES=(
	'steam'
	'lutris'
	'bottles'
)

${choice_optional_pkgs}='-'
echo "Optional Packages:"
for PKG in "${OPTIONAL_PACMAN_PACKAGES}";
do
	echo "${PKG}"
done

${choice_gaming_pkgs}='-'
echo
echo
echo "Gaming Packages:"
for PKG in "${GAMING_PACKAGES}";
do
	echo "${PKG}"
done

while [[ ${choice_optional_pkgs} != 'y' && ${choice_optional_pkgs} != 'Y' &&  ${choice_optional_pkgs} != 'n' && ${choice_optional_pkgs} != 'N' ]];
do
	read "choice_optional_pkgs?Would you like to install optional packages? [yY/nN]"
done

while [[ ${choice_gaming_pkgs} != 'y' && ${choice_gaming_pkgs} != 'Y' &&  ${choice_gaming_pkgs} != 'n' && ${choice_gaming_pkgs} != 'N' ]];
do
	read "choice_gaming_pkgs?Would you like to install gaming packages? [yY/nN]"
done

# Installing packages
for PKG in "${PACMAN_PKGS[@]}";
do
	echo "Installing: ${PKG}"
	pacman -S "$PKG" --noconfirm --needed
done

# Installing packages from AUR
for PKG in "${AUR_PKGS[@]}";
do
	echo "[AUR] Installing: ${PKG}"
	yay -S "$PKG" --noconfirm --needed
done

# Only install the optional packages if user wants to
if [[ "${choice_optional_pkgs}" = 'y' || "${choice_optional_pkgs}" = 'Y']]
then
	for PKG in "${OPTIONAL_PACMAN_PACKAGES[@]}";
	do
		echo "Installing optional package: ${PKG}"
		yay -S "${PKG}" --noconfirm --needed
	done
fi

# Only install the gaming packages if user wants to
if [[ "${choice_gaming_pkgs}" = 'y' || "${choice_gaming_pkgs}" = 'Y']]
then
	for PKG in "${GAMING_PACKAGES[@]}";
	do
		echo "Installing gaming package: ${PKG}"
		yay -S "${PKG}" --noconfirm --needed
	done
fi
