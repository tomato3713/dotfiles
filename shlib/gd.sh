gd() {
  local dir
  dir=$(find "$HOME/code" -name ${1:-.}  -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
