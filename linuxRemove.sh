#!/bin/bash
set -e

# Determine the distro
DISTRO=$(lsb_release -is 2>/dev/null)
if [[ -z "$DISTRO" ]]; then
  echo "Distro not recognized. Exiting."
  exit 1
fi

echo "Undoing installations for $DISTRO..."

# --- Remove Docker and its repositories ---
echo "Removing Docker packages..."
sudo apt-get remove --purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
sudo apt-get autoremove -y || true

echo "Removing Docker repository and keys..."
sudo rm -f /etc/apt/sources.list.d/docker.list || true
sudo rm -rf /etc/apt/keyrings/docker.asc || true

# --- Remove PowerShell ---
echo "Removing PowerShell..."
sudo apt-get remove --purge -y powershell || true

# --- Remove Clangd, .NET, and Java packages ---
echo "Removing Clangd..."
sudo apt-get remove --purge -y clangd-12 || true

echo "Removing .NET SDK..."
sudo apt-get remove --purge -y dotnet-sdk-8.0 || true

echo "Removing Java packages..."
sudo apt-get remove --purge -y default-jre openjdk-8-jre || true

# --- Remove Terraform and its repository ---
echo "Removing Terraform..."
sudo apt-get remove --purge -y terraform || true
sudo rm -f /etc/apt/sources.list.d/hashicorp.list || true
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg || true

# --- Remove Bicep CLI ---
echo "Removing Bicep CLI..."
sudo rm -f /usr/local/bin/bicep || true

# --- Remove Neovim configuration (if installed via the setup) ---
echo "Removing Neovim configuration..."
rm -rf ~/.config/nvim || true

# --- Remove fnm and Node.js installed via fnm ---
echo "Removing fnm installation and references..."
rm -rf ~/.fnm || true
# Remove potential fnm init lines from .bashrc and .zshrc (adjust the grep pattern if needed)
sed -i '/fnm/d' ~/.bashrc || true
sed -i '/fnm/d' ~/.zshrc || true

# --- Undo Zsh and Oh-My-Zsh setup ---
echo "Restoring shell configuration..."
# Change the default shell back to bash
chsh -s /bin/bash

echo "Removing Zsh package..."
sudo apt-get remove --purge -y zsh || true

# --- Remove Microsoft repository (for PowerShell) ---
echo "Removing Microsoft repository list file..."
if [[ "$DISTRO" == "Ubuntu" || "$DISTRO" == "Debian" ]]; then
  sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list || true
fi

# --- Remove docker group membership changes ---
echo "Removing user from docker group..."
sudo gpasswd -d $USER docker || true
# Optionally, remove the docker group if it exists and is empty.
if getent group docker > /dev/null; then
  MEMBERS=$(getent group docker | awk -F: '{print $4}')
  if [[ -z "$MEMBERS" ]]; then
    sudo groupdel docker || true
    echo "Docker group removed."
  else
    echo "Docker group still has members; not deleting."
  fi
fi

# --- Final apt update ---
echo "Updating package lists..."
sudo apt-get update

echo "Undo script completed. Some manual cleanup may still be required (e.g. restoring customized shell config files)."
