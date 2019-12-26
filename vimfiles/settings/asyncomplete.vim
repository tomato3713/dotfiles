let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_compleopt = 0
" Default value is 30
let g:asyncomplete_popup_delay = 200

let g:asyncomplete_remove_duplicates = 1
let g:asyncomplete_smart_completion = 1

" auto close preview window when completion is done.
autocmd! MyAutoCmd CompleteDone * if pumvisible() == 0 | pclose | endif

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ asyncomplete#force_refresh()
inoremap <expr><S-TAB> pumvisible() ? '\<C-p>' : '\<C-h>'

