gd() {
  local dir
  dir=$(find "/home/tomato/code/src/" -name ${1:-.}  -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
