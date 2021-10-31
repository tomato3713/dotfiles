# Dotfiles

Clone this repository and create symbolic link for some files.

Set environment variable XDG_CONFIG_HOME to ~/.config.

## Requirements

- Okular
- ghq
- git
- FZF
- LaTeX
- NeoVim, Language Server (Clang, gopls, ...) & CoC Client
- textlint
- denops
- nyagos & Windows Terminal

I use [PlemolJP](https://github.com/yuru7/PlemolJP) in terminal emulator and text editor.

## Shell script Functions

- cr(): change directory to source code directory by searching FZF command.

## shlib directory

pathfind.sh, save-shell.sh, show-identical-files.sh, taglist.sh referred to "[詳細シェルスクリプト](https://www.oreilly.co.jp/books/4873112672/)"

## For Windows

Profileを表示するスクリプト

``` powershell
echo $Profile.AllUsersAllHosts
echo $Profile.AllUsersCurrentHost
echo $Profile.CurrentUserAllHosts
echo $Profile.CurrentUserCurrentHost
```

## Windows Terminal Profile

```config
"profiles":
{
    "defaults":
    {
        "fontSize": 9,
        "scrollbarState": "hidden",
        "padding": "2, 2, 2, 2"
    },
}
```
