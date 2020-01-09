if empty(globpath(&rtp, 'plugged/JpFormat.vim'))
    finish
endif

" gqコマンドを実行前に自動整形をオフにする
nnoremap <silent> <expr> gq JpFormat_cmd("gq")
" .txt, .mdで自動整形を有効にする。
autocmd MyAutoCmd FileType markdown call s:set_autoformat()
autocmd MyAutoCmd FileType text call s:set_autoformat()
autocmd MyAutoCmd FileType help call s:set_japanese_document_format()
function! s:set_autoformat()
    let JpCountChars=80
    let JpCountOverChars=1
    set formatexpr=jpfmt#formatexpr()
endfunction
function! s:set_japanese_document_format()
    " change important keyword the last of lines ' >' and the top of lines '<'
    if &buftype !=# 'help'
        highlight ignore ctermfg=red
        syntax match Error /\%>79v.*/
        syntax match Error /、\s/
        syntax match Error /。\s/
        set colorcolumn=+1
        let JpCountOverChars = 1
        set formatexpr=jpfmt#formatexpr()
        if has('conceal')
            setlocal conceallevel=0
        endif
    endif
endfunction
