#! /bin/sh
#
# nodejs : nvm を使用して、nodejsをインストールします。
#
# Usage:
# 	~/.dotfiles/node_inst.sh

# 0以外の終了ステータスが出た瞬間にスクリプトを止める。

IFS='
'

set -e

# sudo権限でなければ実行できない
if [ ${EUID:-${UID}} != 0 ]; then
    echo 'Not root user'
    exit 1
fi

cd ~/
git clone https://github.com/creationix/nvm.git .nvm

cd ~/.nvm
# activate nvm by souircing it from your shell
nvm.sh

# install latest node
# node is an alias for the latest version
nvm install node
