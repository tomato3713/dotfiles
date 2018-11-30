#! /bin/sh
#
# vim : githubのコードから最新のバージョンをビルドし、インストールする。
# ruby, golang, pyenv, nodejsはanyenvを利用して、バージョンを管理する。
#
# Usage:
# 	~/.dotfiles/install.sh

# 0以外の終了ステータスが出た瞬間にスクリプトを止める。

IFS='
 	'

set -e

# Install Section

# sudo権限でなければ実行できない
if [ ${EUID:-${UID}} != 0 ]; then
    echo 'Not root user'
    exit 1
fi

apt update
apt -y upgrade

# Golang {{{
echo "install golang"
apt -y install golang-go
# }}}

# Java {{{
echo "install java"
apt -y install default-jre
# }}}

# For Latest Vim {{{
apt -y install libxmu-dev libgtk3.0-dev libxpm-dev build-essential install python3-dev ruby-dev

setSymbolicLink() {
    # Symbolic Link
    if [ ! -e ~/.vim ]; then
        ln -sf ~/.dotfiles/vimfiles ~/.vim
    fi
}

build_vim() {
    # Build Vim {{{
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
        --enable-gui=yes
        --enable-rubyinterp=yes \
        --enable-luainterp=yes \
        --enable-python3interp=yes \
        --prefix=/usr/local \
        --with-features=huge \

    make

    if [ ! -e ~/vim/vim ]; then
        make install
    fi

    vim +":PlugInstall" + ":q" + ":q"
    # }}}

    echo "source ~/.dotfiles/.bash_setting" >> ~/.bashrc
}

install_anyenv() {
    # Anyenv {{{
    git clone https://github.com/riywo/anyenv ~/.anyenv
    echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(anyenv init -)"' >> ~/.bash_profile
    exec $SHELL -l
    # install rbenv, pyenv, goenv, ndenv
    anyenv install rbenv
    anyenv install pyenv
    anyenv install goenv
    anyenv install ndenv
    # If install by anyenv, do this ...
    anyenv version
    exec $SHELL -l
    # }}}
}

set_node() {
}
