if empty(globpath(&rtp, 'plugged/vim-easy-align'))
    finish
endif

vmap <Enter> <Plug>(EasyAlign)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" disable &foldmethod during alignment
let g:easy_align_bypass_fold = 1
