#!/bin/bash

# Function to print messages with colors
print_step() {
    echo -e "\033[1;34m$1\033[0m"
}

print_info() {
    echo -e "\033[1;32m$1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

# Set non-interactive frontend for tzdata
print_step "Configuring tzdata..."
export DEBIAN_FRONTEND=noninteractive
sudo ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Update and upgrade packages
print_step "Updating and upgrading packages..."
sudo apt update

# Install utilities
print_step "Installing utilities..."
sudo apt install -y curl wget git vim nano zsh sudo python3 python3-pip gcc fontconfig unzip ripgrep fzf fd-find jq stow expect gpg

# Install Oh My Zsh using expect to handle the prompt
print_step "Installing Oh My Zsh..."
expect <<- DONE
  set timeout -1
  spawn sh -c "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh"
  expect "Do you want to change your default shell to zsh? (Y/n)" { send "Y\r" }
  expect eof
DONE

# Change the default shell to Zsh
print_step "Changing default shell to Zsh..."
sudo chsh -s $(which zsh) $(whoami)

# Install Neovim
print_step "Installing Neovim..."
cd && curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
export PATH="$PATH:/opt/nvim-linux64/bin"
rm nvim-linux64.tar.gz

# Install Nerd Fonts
print_step "Installing Nerd Fonts..."
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts
rm JetBrainsMono.zip

# Install bat
print_step "Installing bat..."
sudo apt install -y bat
sudo ln -s /usr/bin/batcat /usr/local/bin/bat

# Add alias to .zshrc
print_info "Adding alias for bat to .zshrc..."
echo 'alias bat="batcat"' >> ~/.zshrc

# Install Node.js via nvm
print_step "Installing Node.js via nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install 20

# Install tldr for better man pages
print_step "Installing tldr..."
npm install -g tldr

# Install eza (better ls)
print_step "Installing eza..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# Install Lazygit
print_step "Installing Lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
rm lazygit.tar.gz

# Install tmux
print_step "Installing tmux..."
sudo apt install -y tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Setup Fd command
print_step "Setting up fd command..."
FD_PATH=$(which fdfind)
sudo ln -s $FD_PATH /usr/local/bin/fd

# Ensure SSH directory exists and add GitHub to known hosts
print_step "Ensuring SSH directory exists and adding GitHub to known hosts..."
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone dotfiles repository
print_step "Cloning dotfiles repository..."
git clone https://github.com/nkeneng/dotfiles.git

cd ~/dotfiles
print_step "Stowing dotfiles..."
stow fzf tmux config misc

# Add source line to .zshrc
print_step "Adding source line to .zshrc..."
echo 'source ~/.includes.zsh' >> ~/.zshrc
echo 'source ~/.nvm/nvm.sh' >> ~/.zshrc

print_info "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
