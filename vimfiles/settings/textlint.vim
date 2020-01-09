if empty(globpath(&rtp, 'plugged/vim-textlint'))
    finish
endif

function! s:textlint_after(...)
    execute ':QuickfixStatusEnable'
    execute ':HierUpdate'
endfunction
let g:textlint_callbacks = {
            \ 'after_run': function('s:textlint_after')
            \ }
autocmd BufWritePost *.md call textlint#run()
autocmd InsertLeave *.md call textlint#run()
" TextChanged triggered very often, turn off if Vim is slow.
autocmd TextChanged,TextChangedI *.md call textlint#run()
