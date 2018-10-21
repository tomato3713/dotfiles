#! /bin/bash
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

# Symbolic Link
if [ ! -e ~/vim ]; then
        ln -sf ~/.dotfiles/vimfiles ~/.vim
fi
echo "source ~/.dotfiles/.bash_setting" >> ~/.bashrc

# Build Vim
if [ ! -e ~/vim ]; then
        mkdir ~/vim
fi
if [ ! -e ~/vim/vim ]; then
        # ~/vim/vimが存在しなければgit cloneする。
        git clone https://github.com/vim/vim.git ~/vim/vim
else
		cd ~/vim/vim/
		git pull
fi
# Build Process Start
cd ~/vim/vim/src
make distclean
./configure \
        --enable-multibyte --enable-multibyte --enable-fontset \
        --enable-gui=yes --enable-gui=gtk2 \
        --enable-rubyinterp=dynamic \
        --enable-luainterp=dynamic \
        --enable-python3interp=dynamic \
        --with-features=huge \
make
make install

vim +":PlugInstall" + ":q" + ":q"
