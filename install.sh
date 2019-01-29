#! /bin/sh
#
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
