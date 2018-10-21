echo "Your shell is ${SHELL}"

# some more git aliases
alias gitsts='git status'
alias cls='clear'

export DISPLAY=localhost:0.0

# For Golang
export GOROOT=/usr/lib/go/
export GOPATH=$HOME/go
export PATH=$PATH:/usr/lib/go/bin
export PATH=$PATH:$GOPATH/bin
