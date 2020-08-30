# open explorer
function el {
    <#
    .synopsis
    Open Explorer with the specified PATH.

    .Example
    # Open Explorer with current directory.
    el
    
    .Example
    el C:\

    .Example
    el -path C:\

    #>
    param (
        [String] $path = '.'
    )
    explorer $path
}

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

function Write-PDF {
    <#
    .synopsis
    Compile from LaTeX file to PDF File.
    "Write-PDF report" is equivalent to "platex report.tex ; platex report.tex ; dvipdfmx report.dvi"

    .Example
    Write-PDF
    
    .Example
    Write-PDF report

    .Example
    el -file report

    #>
    param (
        [String] $file = 'report'
    )

    $latex_file = "${file}.ltx"
    $result = (Test-Path $latex_file)
    if (!$result) {
        $latex_file = "${file}.tex"
    }
    Write-Host "Compiling ${latex_file}..."

    platex "${latex_file}" ; pbibtex "${file}"; platex "${latex_file}" ; platex "${latex_file}" ; dvipdfmx "${file}.dvi"
}

function povray {
    param (
        [string] $file = "main.pov"
    )

    pvengine /EXIT /RENDER $file
}

# additional alias
Set-Alias grep Select-String
Set-Alias go 'C:\dev\bin\Go\bin\go.exe'
Set-Alias nkf 'C:\dev\bin\nkf32.exe'
Set-Alias inkscape 'C:\dev\bin\inkscape\bin\inkscape.exe'
# 将来的に texlive も C:\dev\bin 以下に格納するように変更．
Set-Alias platex 'C:\texlive\2020\bin\win32\platex.exe'
Set-Alias dvipdfmx 'C:\texlive\2020\bin\win32\dvipdfmx.exe'
Set-Alias pbibtex 'C:\texlive\2020\bin\win32\pbibtex.exe'
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

# Customize prompt for Git
Import-Module posh-git
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # # Reset color, which can be messed up by Enable-GitColors
    # $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    # posh-gitの出力
    Write-VcsStatus

    # カレントディレクトリの出力.改行無し
    $idx = $pwd.ProviderPath.LastIndexOf("\")+1
    Write-Host($pwd.ProviderPath.Remove(0, $idx)) -nonewline

    # 改行
    Write-Host 

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "$('>' * ($nestedPromptLevel + 1)) "
}

# Gitの情報を表示する部分を括る文字を変更する.
$global:GitPromptSettings.BeforeText = '['
$global:GitPromptSettings.AfterText  = '] '
# $global:GitPromptSettings.DefaultPromptAbbreviateHomeDirectory=$true