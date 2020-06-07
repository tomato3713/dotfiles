# Dotfiles

## Installation

```sh
curl -L raw.github.com/tomato3713/dotfiles/master/install.sh | bash
```

## Using Software

- Zathura
- ghq
- git
- FZF
- LaTeX
- Language Server (Clang, gopls, ...)
- textlint

## Shell script Functions

- cr(): change directory to source code directory by searching FZF command.

## shlib directory

pathfind.sh, save-shell.sh, show-identical-files.sh, taglist.sh referred to "[詳細シェルスクリプト](https://www.oreilly.co.jp/books/4873112672/)"



## For Windows
Windows 用に powershell ディレクトリによく使う関数を格納しています．
以下のようなスクリプトをPowershellが起動時に読み込むファイルのいずれかに書き込んでください．

``` powershell
$script = "$(ghq root)\github.com\tomato3713\powershells\profile.ps1"
if (Test-Path $script) {
  . $script
}
```

Profileを表示するスクリプト

``` powershell
echo $Profile.AllUsersAllHosts
echo $Profile.AllUsersCurrentHost
echo $Profile.CurrentUserAllHosts
echo $Profile.CurrentUserCurrentHost
```