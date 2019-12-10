cr() {
  local dir
  dir=$(find "${GOPATH}/src/" -name ${1:-.}  -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
