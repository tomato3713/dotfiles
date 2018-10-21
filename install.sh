#! /bin/bash
# Symbolic Link
ln -sf ~/.dotfiles/vimfiles ~/.vim
echo "source ~/.dotfiles/.bash_setting" >> ~/.bashrc

# Install Section
apt update
apt -y upgrade
# For Golang
echo "install golang"
apt -y install golang-go
echo "install rbenv and ruby"
# For Latest Vim
apt -y install libxmu-dev libgtk3.0-dev libxpm-dev build-essential
apt -y install python3-dev ruby-dev

# Build Vim
git clone https://github.com/vim/vim.git ~/vim
cd ~/vim/src
./configure \
        --enable-multibyte --enable-multibyte --enable-fontset \
        --enable-gui=yes --enable-gui=gtk2 \
        --enable-rubyinterp=dynamic \
        --enable-luainterp=dynamic \
        --enable-python3interp=dynamic \
        --with-features=huge \
make
make install
