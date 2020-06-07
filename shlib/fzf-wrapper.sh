#! /bin/sh -

# Usage:
#   fd depth base-directory
#
# Example:
#   cd `fd -d 3 -p $HOME`
#   cd `fd -d 3 -p \`ghq root\``

# fd - search directory
fd() {
    local OPTIND OPTARG OPT
    local depth
    local path
    while getopts ":d:p:" OPT ; do
        case $OPT in
            d)
                depth=$OPTARG
                ;;
            p)
                path=$OPTARG
                ;;
            \?)
                echo nothing option
                return 1
                ;;
        esac
    done

    local dir
    dir=$(find ${path:-.} -path '*/\.*' -prune -o -type d -print -maxdepth ${depth:-5} \
        2> /dev/null | fzf +m) &&
        echo $dir
    }

# fr - search repositories
alias fr='fd -d 3 -p `ghq root`'
