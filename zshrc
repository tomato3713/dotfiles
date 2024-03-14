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
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks

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
# ----------- Shortcut --------------
# -----------------------------------
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
