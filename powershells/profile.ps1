# set prompt for colorful
function prompt {
    Write-Host "$env:USERNAME " -ForegroundColor "Green" -NoNewline
    Write-Host "$pwd " -ForegroundColor Magenta -NoNewline
    Write-Host "$" -ForegroundColor "Green" -NoNewline
    return " "
}

# open explorer
function el() { explorer .}

# find directory
function fd{
    <#
    .synopsis
    Display a list of relative paths from the current directory to the specified depth.

    .Example
    fd | fzf | cd
    .Example
    fd -depth 3 -path $HOME | fzf | cd
    #>
    param (
        [Int] $depth = 3,
        [String] $path = '.'
    )
    $origin = [System.Console]::OutputEncoding
    $utf8 = [System.Text.Encoding]::GetEncoding("utf-8")
    $OutputEncoding = $utf8
    [System.Console]::OutputEncoding = $utf8

    $out = (Get-ChildItem -Name -Directory -Depth $depth -Path $path | fzf)
    
    [System.Console]::OutputEncoding = $origin
    return $out
}

# additional alias
Set-Alias grep Select-String
# set environment variable
Set-Item env:LESSCHARSET -value "utf-8"

# bash like keybinds
Set-PSReadlineKeyHandler -Key 'Ctrl+u' -Function BackwardDeleteLine
Set-PSReadlineKeyHandler -Key 'Ctrl+b' -Function BackwardChar
Set-PSReadlineKeyHandler -Key 'Ctrl+f' -Function ForwardChar
Set-PSReadlineKeyHandler -Key 'Ctrl+d' -Function DeleteChar
Set-PSReadlineKeyHandler -Key 'Ctrl+h' -Function BackwardDeleteChar
Set-PSReadlineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key 'Ctrl+a' -Function BeginningOfLine
Set-PSReadlineKeyHandler -Key 'Ctrl+e' -Function EndOfLine