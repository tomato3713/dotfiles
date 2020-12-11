#! /bin/sh -
#
# 環境変数として指定されたパスに対して、ファイル名またはこれを表す
# パターンを使って探索を行います。
#
# 特に指定がない場合、最初に発見されたファイルの完全なパス名が標準
# 出力に出力されます。ファイルが1つも見つからなければ、標準エラー
# 出力にエラーメッセージを書き出します。
#
# 指定されたファイルがすべて発見された場合は終了ステータスとして0を
# 返します。見つからないファイルがあった場合は、その個数が終了ステ
# ータスとして使われます。( 正し、終了ステータスの値には125という
# 上限値が定められています。
#
# Usage:
#   pathfind [--all] [--?] [--help] [--version] envvar pattern(s)
#
# --allオプションを指定すると、パス中のすべてのディレクトリが探索さ
# れ、マッチしたファイルはすべて表示されます。

# IFSに改行、タブ、スペースをセットする。
IFS='
 	'
# 信頼できる場所からのみプログラムを呼び出すようにする。
OLDPATH="$PATH"
PATH=/bin:/usr/bin
export PATH

error()
{
    echo "$@" 1>&2
    usage_and_exit 1
}

usage()
{
    echo "Usage: $PROGRAM [--all] [--?] [--help] [--version] envvar pattern(s)"
}

usage_and_exit()
{
    usage
    exit $1
}

version()
{
    echo "$PROGRAM version $VERSION"
}

warning()
{
    echo "$@" 1>&2
    EXITCODE=`expr $EXITCODE + 1`
}

# 本体部分
all=no
envvar=
EXITCODE=0
PROGRAM=`basename $0`
VERSION=1.0

while test $# -gt 0
do
    case $1 in
        --all | --a | -all | -a )
            all=yes
            ;;
        --help | --h | '--?' | -help | -h | '-?' )
            usage_and_exit 0
            ;;
        --version | --ver | --v | -v | -version | -ver )
            version
            exit 0
            ;;
        -*)
            error "認識できないオプションです: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done

envvar="$1"
test $# -gt 0 && shift
# xはenvvarが-から始まっていた場合にtestコマンドのオプションとみなされないようにするため
test "x$envvar" = "xPATH" && envvar=OLDPATH

dirpath=`eval echo '${'"$envvar"'}' 2>/dev/null | tr : ' ' `

# 不正な条件が発生していないかどうか調べます
if test -z "$envvar"
then
    error 環境変数が存在しないか、その値が空です。
elif test "x$dirpath" = "x$envvar"
then
    error "shプログラムが正しく機能していません。$envvarを展開できません。"
elif test -z "$dirpath"
then
    error 探索パスが空です
elif test $# -eq 0
then
    exit 0
fi

for pattern in "$@"
do
    result=
    for dir in $dirpath; do
        for file in $dir/$pattern; do
            if test -f "$file"; then
                result="$file"
                echo $result
                test "$all" = "no" && break 2
            fi
        done
    done
    test -z "$result" && warning "$pattern: Not Found"
done

# Unixでの流儀に従い、終了ステータスの値の上限値を超えないようにします。
test $EXITCODE -gt 125 && EXITCODE=125
exit $EXITCODE
