" ====================================================
" Vim global plugin for learning vim.
" Last Change: 2017 Sept 26
" Maintainer: taichi watanabe <weasel.wt@outlook.com>
" File: cheatsheet.vim
" ====================================================

scriptencoding utf-8

let s:save_cpo= &cpo
set cpo&vim

" vim script
function! cheatSheet#main()
  set laststatus=2
  set statusline=%!cheatSheet#makeCheatSheet()
endfunction


function! cheatSheet#makeCheatSheet()
  "現在のモードで分岐
  let l:mode=mode()

  if (mode=="n")
    "ノーマルモード
    let s:cheatSheet_line="i, a=insert mode, j=down k=up h=left l=right x=delete under cursor, y{motion}=yank, u=undo, ^r=redo, :=enter command"
  endif

  if (mode=="i")
    "インサートモード
    let s:cheatSheet_line="^n, p=completion, ^x+f=filename completion, ^t=add indent, ^d=decrease indent"
  endif

  if (mode=="V" || mode=="v" || mode=="^V")
    let s:cheatSheet_line="w=start of next word, b=begin of current word, 0=start of the line, $=end of the line"
  endif

  return s:cheatSheet_line
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
