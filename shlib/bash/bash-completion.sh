# shellcheck shell=bash
# memo command completion function
_go_memo(){
    # shellcheck disable=SC2034  # _get_comp_words_by_ref が参照渡しで設定する
    local prev cur cword
    # get the input informations (ref: /usr/share/bash-completion/bash_completion )
    _get_comp_words_by_ref -n : cur prev cword
    opts="new list edit cat delete grep config serve"

    mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
} &&
complete -F _go_memo memo
