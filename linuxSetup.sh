#!/bin/bash

# Determine the distribution
DISTRO=$(lsb_release -is 2>/dev/null)

print_message() {
    echo "================================================="
    echo "$1"
    echo "================================================="
}

if [[ "$DISTRO" == "Ubuntu" ]]; then
    # Ubuntu setup
    sudo apt-get install -y wget apt-transport-https software-properties-common
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    source /etc/os-release
    wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y powershell
    sudo apt update && sudo apt upgrade -y
    sudo apt-get install -y clangd-19
    sudo apt-get install -y dotnet-sdk-8.0
    sudo apt install -y default-jre openjdk-8-jre openjdk-19-jre npm

elif [[ "$DISTRO" == "Debian" ]]; then
    # Debian setup
    sudo apt-get install -y wget
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    source /etc/os-release
    wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y powershell
    sudo apt update && sudo apt upgrade -y
    sudo apt-get install -y clangd-19
    sudo apt-get install -y dotnet-sdk-8.0
    sudo apt install -y default-jre openjdk-8-jre openjdk-19-jre npm

elif [ -f "/etc/arch-release" ]; then
    # Arch Linux setup
    sudo pacman -S --noconfirm zsh docker docker-compose
    sudo systemctl enable docker.service
    sudo pacman -S --noconfirm dotnet-runtime-8.0 dotnet-sdk-8.0
    sleep 10
    dotnet tool install --global PowerShell

elif [ -f "/etc/fedora-release" ]; then
    # Fedora setup
    print_message "Setting up for Fedora"
    sudo dnf install -y wget curl ca-certificates dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo rpm -Uvh https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/packages-microsoft-prod.rpm
    sudo dnf update -y
    sudo dnf install -y powershell dotnet-sdk-8.0 dotnet-runtime-8.0
    sudo dnf install -y clang clang-tools-extra
    sudo dnf install -y nodejs npm
    sudo dnf install -y zsh

elif grep -qi "opensuse" /etc/os-release; then
    # openSUSE setup
    print_message "Setting up for openSUSE"
    sudo zypper refresh
    sudo zypper install -y wget curl ca-certificates
    sudo zypper install -y docker docker-compose
    sudo systemctl enable docker && sudo systemctl start docker
    sudo wget -O /etc/zypp/repos.d/microsoft-prod.repo https://packages.microsoft.com/config/opensuse/15/prod.repo
    sudo zypper refresh
    sudo zypper install -y powershell
    sudo zypper install -y dotnet-sdk-8.0
    sudo zypper install -y clang clang-tools-extra
    sudo zypper install -y nodejs npm
    sudo zypper install -y zsh

else
    echo "No supported Distro for install found"
    exit 1
fi

# Docker group setup
if ! getent group docker > /dev/null; then
    echo "Group 'docker' does not exist. Creating it now..."
    sudo groupadd docker
    echo "Group 'docker' created successfully."
else
    echo "Group 'docker' already exists."
fi
sudo usermod -aG docker $USER

# Terraform installation
if [ -f "/etc/arch-release" ]; then
    sudo pacman -S --noconfirm terraform
elif [[ "$DISTRO" == "Ubuntu" || "$DISTRO" == "Debian" ]]; then
    wget -O go0.24.0.linux-amd64.tar.gz https://go.dev/dl/go1.24.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go0.24.0.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install -y terraform
elif [ -f "/etc/fedora-release" ]; then
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install -y terraform
elif grep -qi "opensuse" /etc/os-release; then
    sudo zypper addrepo -f https://rpm.releases.hashicorp.com/opensuse/hashicorp.repo
    sudo zypper refresh
    sudo zypper install -y terraform
fi

# Fetch the latest Bicep CLI binary
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
chmod +x ./bicep
sudo mv ./bicep /usr/local/bin/bicep

# Install and setup Neovim using the local NvimSetup.sh
bash ./NvimSetup.sh

# Download and install fnm
curl -o- https://fnm.vercel.app/install | bash

# Download and install Node.js version 22 via fnm
fnm install 22

# Verify installations
node -v
npm -v

# Install Oh-My-Zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Oh-My-Zsh plugins
zsh -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
zsh -c "git clone https://github.com/zsh-users/zsh-autosuggestions.git \$ZSH_CUSTOM/plugins/zsh-autosuggestions"

wget -O ~/.zshrc https://raw.githubusercontent.com/SykesTheLord/AutoLinuxSetup/refs/heads/main/.zshrc

# Install Terraform autocomplete
terraform -install-autocomplete

# Install Azure Shell module
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"

print_message "Now run chsh -s \$(which zsh)"
