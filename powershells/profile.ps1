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
    fd 5 | fzf | cd
    #>
    param (
        [Int] $depth = 3
    )
    $origin = [System.Console]::OutputEncoding
    $utf8 = [System.Text.Encoding]::GetEncoding("utf-8")
    $OutputEncoding = $utf8
    [System.Console]::OutputEncoding = $utf8

    $out = (Get-ChildItem -Name -Directory -Depth $depth | fzf)
    
    [System.Console]::OutputEncoding = $origin
    return $out
}

# additional alias
Set-Alias grep Select-String