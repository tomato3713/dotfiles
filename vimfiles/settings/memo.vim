if empty(globpath(&rtp, 'plugged/memolist.vim'))
    finish
endif

let g:memolist_path = expand('$HOME/code/src/github.com/tomato3713/notebox/memo')
let g:memolist_template_dir_path = expand('$HOME/.vim/template/memolist/')
let g:memolist_memo_suffix = 'md'
let g:memolist_memo_date = '%Y-%m-%d %H:%M'

