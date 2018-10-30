# 終了ステータスのみ利用したい場合の書き方の例
if grep pattern myfile > /dev/null
then
    パターンが見つかった時
else
    見つからなかった場合
fi


# passwordの入力等で必ず人出で入力してほしいデータを読み込む場合などに便利なファイル
printf "New Password"
stty -echo              # 入力された文字が表示されるのを防ぐ
read pass < /dev/tty    # パスワードを読み込みます
printf "Confirm Password"
read pass2 < /dev/tty   # もう一度パスワードを読み込みます
stty echo               # 画面表示をもとに戻します。
