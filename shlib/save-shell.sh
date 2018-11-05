#! /bin/bash
#
# 関数の定義も含めて、シェルの状態を/tmp/shell.stateに保存します。
#
# Usage:
# save-shell

{
    set +o # シェルのオプション項目
    (shopt -p) 2>/dev/null # bash固有の設定
    set # 変数とその値
    export -p # 環境に追加された変数
    readonly -p # 読み取り専用の変数
    trap # trapの設定

    typeset -f # 関数の定義(非POSIX)
} > /tmp/shell.state
