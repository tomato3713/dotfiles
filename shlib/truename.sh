#! /bin/sh
#
# 特殊文字を含めた文字を含めて、ファイル名を正確に表示します。
#
# Usage:
#   truename [pattern]

ls -1 "$@" | od -a -b
