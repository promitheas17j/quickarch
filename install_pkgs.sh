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
	'texlive-basic'
	'zathura'
	'zathura-pdf-poppler'
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
	'nerd-fonts-meta'
	'spotify'
)

OPTIONAL_PACMAN_PACKAGES=(
	'qemu-full'
	'qemu-emulators-full'
)

${choice_optional_pkgs}='-'

while [[ ${choice_optional_pkgs} != 'y' && ${choice_optional_pkgs} != 'Y' &&  ${choice_optional_pkgs} != 'n' && ${choice_optional_pkgs} != 'N'  ]];
do
	read "choice_optional_pkgs?Would you like to install optional packages? [yY/nN]"
done

# Installing packages
for PKG in "${PACMAN_PKGS[@]}";
do
	echo "Installing: ${PKG}"
	pacman -S "$PKG" --noconfirm --needed
done

# Only install the optional packages if user wants to
if [[ "${choice_optional_pkgs}" = 'y' || "${choice_optional_pkgs}" = 'Y']]
then
	for PKG in "${OPTIONAL_PACMAN_PACKAGES[@]}";
	do
		echo "Installing optional package: ${PKG}"
		pacman -S "${PKG}" --noconfirm --needed
	done
fi

# Installing packages from AUR
for PKG in "${AUR_PKGS[@]}";
do
	echo "[AUR] Installing: ${PKG}"
	yay -S "$PKG" --noconfirm --needed
done
