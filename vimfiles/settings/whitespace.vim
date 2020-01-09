if empty(globpath(&rtp, 'plugged/vim-better-whitespace/'))
    finish
endif

let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
let g:strip_whitespace_confirm=0 " not confirm before white space is stripped."
