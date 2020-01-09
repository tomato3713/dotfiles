if empty(globpath(&rtp, 'plugged/sonictemplate-vim'))
    finish
endif

" Tell My Template Directory
let g:sonictemplate_vim_template_dir = [ '~/.vim/template' ]
let g:sonictemplate_vim_vars = {
            \ '_': {
            \   'author': 'Taichi Watanabe',
            \ },
            \}

