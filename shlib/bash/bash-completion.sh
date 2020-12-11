# memo command completion function
_go_memo(){
    local prev cur cword
    # get the input informations (ref: /usr/share/bash-completion/bash_completion )
    _get_comp_words_by_ref -n : cur prev cword
    opts="new list edit cat delete grep config serve"

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
} &&
complete -F _go_memo memo
