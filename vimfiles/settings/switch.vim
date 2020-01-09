if empty(globpath(&rtp, 'plugged/switch.vim'))
    finish
endif

let g:switch_mapping = '+'
let g:switch_reverse_mapping = '-'
