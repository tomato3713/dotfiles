#! /bin/sh
#
# vim : githubのコードから最新のバージョンをビルドし、インストールする。
#
# Usage:
# 	~/.dotfiles/vim_inst.sh

# 0以外の終了ステータスが出た瞬間にスクリプトを止める。

IFS='
'

set -e

# sudo権限でなければ実行できない
if [ ${EUID:-${UID}} != 0 ]; then
    echo 'Not root user'
    exit 1
fi

apt update
apt -y upgrade

apt -y install libxmu-dev libgtk3.0-dev libxpm-dev build-essential install python3-dev ruby-dev libcanberra-dev

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
    --enable-fail-if-missing \
    --with-features=huge \
    --enable-luainterp=dynamic \
    --enable-python3interp=dynamic \
    --enable-rubyinterp=dynamic \
    --enable-cscope \
    --enable-fontset \
    --enable-multibyte \
    --enable-luainterp \
    --enable-perlinterp \
    --enable-terminal \
    --enable-gui=yes

if [ -e make ]; then
    make install
fi

# Symbolic Link
if [ ! -e ~/.vim ]; then
    ln -sf ~/.dotfiles/vimfiles ~/.vim
fi

vim +":PlugInstall" + ":qa"
