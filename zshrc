# -----------------------------------
# -------- ENABLE FEATURE -----------
# -----------------------------------
autoload -U compinit; compinit; zstyle ":completion:*:commands" rehash 1
autoload -U colors; colors

# completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
    autoload -Uz compinit
    compinit
fi

# -----------------------------------
# ------------ History --------------
# -----------------------------------
export HISTSIZE=100000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt share_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
function history-all { history -E 1 }
# http://mollifier.hatenablog.com/entry/20090728/p1
zshaddhistory() {
    local line=${1%%$'\n'} #コマンドライン全体から改行を除去したもの
    local cmd=${line%% *}  # １つ目のコマンド
    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 5
        && ${cmd} != (l[sal])
        && ${cmd} != (cd)
        && ${cmd} != (man)
        && ${cmd} != (git [(status)|(diff)])
    ]]
}
# -----------------------------------
# ------------- PATH ----------------
# -----------------------------------
export PATH="`go env GOPATH`/bin:$PATH"

# -----------------------------------
# ------------- Alias ---------------
# -----------------------------------
alias n=nvim --cmd "let g:useShared=v:true" $*
alias nn=nvim $*
alias g=git
alias gcd='cd `git rev-parse --show-toplevel`'

# -----------------------------------
# ------- Custom Functions ----------
# -----------------------------------
tgz() {
    # Usage: tgz nekotoma.tgz file1 file2 dir1 dir2
    env COPYFILE_DISABLE=1 tar zcvf "$1" --exclude=".DS_Store" "${@:2}"
}

ghq-cd () {
    if [ -n "$1" ]; then
        dir="$(ghq list --full-path --exact "$1")"
        if [ -z "$dir" ]; then
            echo "no directories found for '$1'"
            return 1
        fi
        cd "$dir"
        return
    fi
    echo 'usage: ghq-cd $repo'
    return 1
}

peco-src () {
    local repo=$(ghq list | peco --query "$LBUFFER")
    if [ -n "$repo" ]; then
        repo=$(ghq list --full-path --exact $repo)
        BUFFER="cd ${repo}"
        zle accept-line
    fi
    zle clear-screen
}

start-emacs-daemon() {
     emacs --fg-daemon
}
# -----------------------------------
# ----------- Shortcut --------------
# -----------------------------------
zle -N peco-src
bindkey '^]' peco-src

# -----------------------------------
# ------------ PROMPT ---------------
# -----------------------------------
git_prompt() {
  local branchname
  branchname=`git symbolic-ref --short HEAD 2> /dev/null`
  if [ -z $branchname ]; then
    PROMPT="%~"$'\n'"%# "
  fi
  PROMPT="%~ ($branchname)"$'\n'"%# "
}
precmd() {
  git_prompt
}
