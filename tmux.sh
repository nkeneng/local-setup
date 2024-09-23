
#install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# download tmux configuration
wget https://raw.githubusercontent.com/nkeneng/dotfiles/refs/heads/master/tmux/.tmux.conf -O ~/.tmux.conf

tmux source ~/.tmux.conf
