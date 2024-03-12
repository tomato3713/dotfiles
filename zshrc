# -----------------------------------
# -------- ENABLE FEATURE -----------
# -----------------------------------
autoload -U compinit; compinit
autoload -U colors; colors

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

# -----------------------------------
# ----------- Shortcut --------------
# -----------------------------------
function gcd() {
  local destination_dir=$(echo "$(ghq list --full-path) $ENV_CACHE_SDL" | fzf)
  if [ -n "$destination_dir" ]; then
    BUFFER="cd $destination_dir"
    zle accept-line
  fi
  zle clear-screen
}
zle -N gcd
bindkey '^]' gcd

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
