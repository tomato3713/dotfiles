#! /bin/sh -

setProxy() {
    echo "set proxy"
    echo "$1"
    export http_proxy="$1"
    export https_proxy="$1"
}

unsetProxy() {
    echo "unset proxy"
    export http_proxy=
    export https_proxy=
}

set -u

IFS='
 	'

export LANG="C"

flag=
while test $# -gt 0
do
    case $1 in
        --unset | -unset | -u | --u )
            flag=0
            ;;
        --help | -help | -h | --h | '-?' | '--?' )
            ;;
        -*)
            echo "$0: 不正なオプションです。-$OPTARG" >&2
            echo "Usage: $0 ">&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ $flag ]; then
    unsetProxy()
    exit 0
fi

if [ -z "$flag" ]; then
    proxy="$1"
    setProxy $proxy
fi
