#! /bin/bash
# run-with-color.sh
#
# Shell Script Library
# ステータスコードで失敗と示されている場合には、実行したコマンド列と
# カレントディレクトリの位置を出力します。その後、exitでスクリプトの
# 実行を中断します。
#
# Usage:
#   run [command]

red=31
yellow=33
cyan=36

colored() {
    color=$1
    shift
    echo -e "\033[1;${color}m$@\033[0m"
}

run() {
    "$@"
    result=$?

    if [ $result -ne 0 ]; then
        echo -n $(colored $red "Faild: ")
        echo -n $(colored $cyan "$0")
        echo $(colored $yellow " [$PWD]")
        exit $result
    fi
    return 0
}
