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
    print_message "Setting up for Ubuntu"
    sudo apt update && sudo apt upgrade -y
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
    sudo apt install -y ripgrep
    sudo apt install -y direnv

elif [[ "$DISTRO" == "Debian" ]]; then
    # Debian setup
    print_message "Setting up for Debian"
    sudo apt update && sudo apt upgrade -y
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
    sudo apt install -y ripgrep
    sudo apt install -y direnv

elif [ -f "/etc/arch-release" ]; then
    # Arch Linux setup
    print_message "Setting up for Arch"
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm zsh docker docker-compose
    sudo systemctl enable docker.service
    sudo pacman -S --noconfirm dotnet-runtime-8.0 dotnet-sdk-8.0
    sleep 10
    sudo dotnet tool install --global PowerShell
    sudo pacman -S --noconfirm ripgrep
    sudo pacman -S --noconfirm direnv

elif [ -f "/etc/fedora-release" ]; then
    # Fedora setup
    print_message "Setting up for Fedora"
    sudo dnf install -y wget curl ca-certificates dnf-plugins-core python3-pip git
    sudo dnf update -y
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo rpm -Uvh https://packages.microsoft.com/config/fedora/$(rpm -E %fedora)/packages-microsoft-prod.rpm
    sudo dnf install -y dotnet-sdk-8.0 dotnet-runtime-8.0 aspnetcore-runtime-8.0
    sudo dnf install -y clang clang-tools-extra
    sudo dnf module install -y nodejs:18/common
    sudo dnf install -y npm18
    sudo dnf install -y zsh
    sudo dotnet tool install --global PowerShell
    sudo dnf install -y ripgrep
    sudo dnf install -y direnv

elif grep -qi "opensuse" /etc/os-release; then
    # openSUSE setup
    print_message "Setting up for openSUSE"
    sudo zypper refresh
    sudo zypper dup -y
    sudo zypper --non-interactive patch
    sudo zypper install -y wget curl ca-certificates
    sudo zypper install -y docker docker-compose
    sudo systemctl enable docker && sudo systemctl start docker
    if grep -qi "opensuse leap 15.6" /etc/os-release; then
        wget -O libopenssl1_0_0-1.0.2u-lp156.133.5.x86_64.rpm https://download.opensuse.org/repositories/home:/MaxxedSUSE:/Compiler-Tools-15.6/15.6/x86_64/libopenssl1_0_0-1.0.2u-lp156.133.5.x86_64.rpm
        sudo rpm -i libopenssl1_0_0-1.0.2u-lp156.133.5.x86_64.rpm
        rm -f libopenssl1_0_0-1.0.2u-lp156.133.5.x86_64.rpm
    else
        wget -O libopenssl1_0_0-1.0.2u-security.146.64.x86_64.rpm https://download.opensuse.org/repositories/home:/ohollmann:/branches:/security:/tls/openSUSE_Tumbleweed/x86_64/libopenssl1_0_0-1.0.2u-security.146.64.x86_64.rpm
        sudo rpm -i libopenssl1_0_0-1.0.2u-security.146.64.x86_64.rpm
        rm -f libopenssl1_0_0-1.0.2u-security.146.64.x86_64.rpm
    fi
    sudo zypper refresh
    sudo zypper install -y libicu
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo wget -O /etc/zypp/repos.d/microsoft-prod.repo https://packages.microsoft.com/config/opensuse/15/prod.repo
    sudo zypper refresh
    sudo zypper install -y clang
    sudo zypper install -y nodejs npm
    sudo zypper install -y zsh
    sudo zypper install -y dotnet-sdk-8.0
    sudo zypper install -y aspnetcore-runtime-8.0
    sudo dotnet tool install --global powershell
    sudo zypper install -y ripgrep
    sudo zypper install -y direnv

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
else
    echo "Download Terrafrom manually from Hashicorp.com" >> toDo.txt
fi

mkdir UserApps

if [[ $(grep -i Microsoft /proc/version) ]]; then
    wget https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x86.zip
    unzip win32yank-x86.zip -d ~/UserApps/win32yank
fi


# Fetch the latest Bicep CLI binary
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
chmod +x ./bicep
sudo mv ./bicep /usr/local/bin/bicep

# Install and setup Neovim using the local NvimSetup.sh
wget -O- https://raw.githubusercontent.com/SykesTheLord/NeoVimConfig/refs/heads/main/NvimSetup.sh | bash NvimSetup.sh 


wget -O ~/.zshrc https://raw.githubusercontent.com/SykesTheLord/AutoLinuxSetup/refs/heads/main/.zshrc
wget -O ~/.config/updateNeovimConf.sh https://raw.githubusercontent.com/SykesTheLord/AutoLinuxSetup/refs/heads/main/updateNeovimConf.sh


# Install Terraform autocomplete
if command -v terraform &>/dev/null; then
    terraform -install-autocomplete
else
    echo "Run the following command: terraform -install-autocomplete" >> toDo.txt
fi

# Install Azure Shell module
pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force"

# Install Oh-My-Zsh
wget -O installZsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh installZsh.sh --unattended --keep-zshrc --skip-chsh
sleep 30
rm -f installZsh.sh

# Install Oh-My-Zsh plugins
zsh -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
zsh -c "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"


wget https://github.com/zen-browser/desktop/releases/download/1.8.2b/zen.linux-x86_64.tar.xz
tar -xJf zen.linux-x86_64.tar.xz -C ~/UserApps

# Open Jetbrains for toolbox link
firefox https://www.jetbrains.com/toolbox-app/download/download-thanks.html?platform=linux

print_message "Now run 'sudo chsh $USER' if on Fedora, otherwise run 'chsh -s \$(which zsh)'. If errors occur"

wget -O- https://raw.githubusercontent.com/SykesTheLord/NeoVimConfig/refs/heads/main/NvimSetup.sh | bash NvimSetup.sh 
