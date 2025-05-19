#!/bin/bash
sudo pacman -S --noconfirm swaync wireplumber pipewire qt6-wayland qt5-wayland kitty wl-clipboard gnome-keyring libsecret slurp grim imagemagick swappy  spotify-launcher pavucontrol rofi blueman qt6ct bitwarden network-manager-applet nwg-look font-config rustc cargo ghostty linux-headers
yay -S hyprland-git
yay -S hyprlock-git
yay -S hyprpaper-git
yay -S hypridle-git
yay -S fastfetch
yay -S wofi
yay -S waybar
yay -S brightnessctl
pacman -S --noconfirm uwsm
# Enable services
sudo systemctl enable swaync
yay -S xdg-desktop-portal-hyprland-git
# Get hyprland setup from dotfiles repo
git clone https://github.com/SykesTheLord/DotFiles.git
cd DotFiles
cd arch
cp -r * ~/

yay -S QGtk3Style
yay -S themix-full-git
yay -S eww
yay -S discord_arch_electron
yay -S hyprsysteminfo
yay -S hyprcursor
yay -S wlogout
yay -S vmware-keymaps
yay -S vmware-workstation
yay -S nordzy-hyprcursors
yay -S nordzy-cursors
