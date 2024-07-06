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

# Set environment variables for Nix
#export NIX_REMOTE=daemon
export NIX_CONF_DIR=/etc/nix
export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs
export NIXPKGS_ALLOW_UNFREE=1
export NIXPKGS_ALLOW_BROKEN=1

# Ensure the Nix configuration directory exists
print_step "Creating Nix configuration directory..."
sudo mkdir -p /etc/nix

# Disable syscall filtering in Nix
print_step "Disabling syscall filtering in Nix..."
echo "sandbox = false" | sudo tee /etc/nix/nix.conf
echo "filter-syscalls = false" | sudo tee -a /etc/nix/nix.conf


apt install wget curl xz-utils -y

# Install Nix package manager
print_step "Installing Nix package manager..."
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

# Source Nix profile script if it exists
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    print_error "Nix profile script not found. Nix installation might have failed."
    exit 1
fi

echo 'export PATH=$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH' >> ~/.zshrc

# Install utilities using Nix
print_step "Installing utilities with Nix..."
nix-env -iA nixpkgs.git nixpkgs.vim nixpkgs.nano nixpkgs.zsh nixpkgs.python3 nixpkgs.python3Packages.pip nixpkgs.gcc nixpkgs.fontconfig nixpkgs.unzip nixpkgs.ripgrep nixpkgs.fzf nixpkgs.fd nixpkgs.jq nixpkgs.stow nixpkgs.expect nixpkgs.gnupg nixpkgs.yazi

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
nix-env -iA nixpkgs.neovim

# Install Nerd Fonts
print_step "Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
unzip ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -fv
rm ~/.local/share/fonts/JetBrainsMono.zip

# Install bat
print_step "Installing bat..."
nix-env -iA nixpkgs.bat

# Install Node.js via nvm
print_step "Installing Node.js via nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \\. "$NVM_DIR/bash_completion"' >> ~/.zshrc  # This loads nvm bash_completion
source ~/.zshrc
nvm install 20

# Install tldr for better man pages
print_step "Installing tldr..."
npm install -g tldr

# Install eza (better ls)
print_step "Installing eza..."
nix-env -iA nixpkgs.eza

# Install Lazygit
print_step "Installing Lazygit..."
nix-env -iA nixpkgs.lazygit

# Install tmux
print_step "Installing tmux..."
nix-env -iA nixpkgs.tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Ensure SSH directory exists and add GitHub to known hosts
print_step "Ensuring SSH directory exists and adding GitHub to known hosts..."
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone dotfiles repository
print_step "Cloning dotfiles repository..."
git clone --recurse-submodules https://github.com/nkeneng/dotfiles.git ~/dotfiles

cd ~/dotfiles
print_step "Stowing dotfiles..."
stow fzf tmux config misc

# Add source line to .zshrc
print_step "Adding source line to .zshrc..."
echo 'source ~/.includes.zsh' >> ~/.zshrc

print_info "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
