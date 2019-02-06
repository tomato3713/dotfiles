#! /bin/sh
#
# golang : github を使用して、golang をインストールします。
#
# Usage:
# 	~/.dotfiles/go_inst.sh

# 0以外の終了ステータスが出た瞬間にスクリプトを止める。

IFS='
'

set -e

# sudo権限でなければ実行できない
if [ ${EUID:-${UID}} != 0 ]; then
    echo 'Not root user'
    exit 1
fi

cd ~
# install Go compiler binaries
apt install gcc libc6-dev
apt install golang-go

export GOROOT_BOOTSTRAP=`which go`

# install golang source code
git clone https://go.googlesource.com/go
cd go/src
./all.bash


# set $GOROOT to my go installed directory
echo 'export GOROOT=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOROOT/bin' >> ~/.bashrc
# set $GOPATH to my workspace
echo 'export GOPATH=$HOME/go-workspace' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc

go version
