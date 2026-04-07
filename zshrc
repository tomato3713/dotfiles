# -----------------------------------
# -------- ENABLE FEATURE -----------
# -----------------------------------
autoload -U compinit; compinit; zstyle ":completion:*:commands" rehash 1
autoload -U colors; colors

# zmodload -a zsh/zpty zpty

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
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_NO_STORE
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
alias n='nvim --cmd "let g:useShared=v:true"' $*
alias nn=nvim $*
alias g=git
alias Gin=git
alias GinBuffer=git
alias python="python3"
# alias gcd='cd `git rev-parse --show-toplevel`'

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

# ------------------------------------
# --------- Insert Datestamp ---------
# ------------------------------------
# 1. 日付を挿入する関数（ウィジェット）を定義
insert-datestamp() {
  LBUFFER="${LBUFFER}$(date +%Y-%m-%d)"
}

# 2. ZLEウィジェットとして登録
zle -N insert-datestamp

# 3. Ctrl-t ( ^T ) に割り当て
bindkey '^T' insert-datestamp

# -----------------------------------
# ------------ PROMPT ---------------
# -----------------------------------
source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
setopt prompt_subst
# Gitリポジトリ以外ではGitリポジトリの状態を表示しない
git_prompt() {
 if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
   # local branchname
   export PROMPT="[%B%F{red}%n@local%f%b:%F{green}%~%f]%F{cyan} ${vcs_info_msg_0_} "$'\n'"> " 
 else
   export PROMPT="[%B%F{red}%n@local%f%b:%F{green}%~%f]%F{cyan}%f"$'\n'"> " 
 fi
}
precmd() {
 vcs_info
 git_prompt
}

