#! /bin/sh -
# コマンドラインで指定されたHTMLやSGML, XMLファイルを読み込み
# <tag>word</tag>のように記述されている箇所を抜き出します。そして以下の
# ような形式でタブ区切りのデータを出力します。それぞれの行は単語とタグの
# 昇順で並べ替えられます。
#
#     出現回数 word tag filename
# Usage:
#     taglist xml-files
#
# CF: 詳細シェルスクリプト(O'Reilly Japan

process() {
    cat "$1" |
        sed -e 's#systemitem *role="url"#URL#g' -e 's#/systemitem#/URL#' |
        tr ' (){}[]' '\n\n\n\n\n\n\n' |
        egrep '>[^<>]+</' |
        awk -F'[<>]' -v FILE="$1" \
        '{ printf("%-31s\t%-15s\t%s\n", $3, $2, FILE) }' |
        sort |
        uniq -c |
        sort -k2 -k3 |
        awk '{
            print ($2 == Last) ? ($0 " <----") : $0
            Last = $2
        }'
}

for f in "$@"
do
    process "$f"
done
