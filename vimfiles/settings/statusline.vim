" display status line
set laststatus=2
set ruler " add cursor line location in right of status line

let g:lightline = {
            \ 'active': {
            \   'left': [ ['mode', 'gitbranch', 'readonly', 'filename', 'modified'] ]
            \ },
            \ 'colorscheme': 'solarized',
            \ 'component_function': {
            \   'gitbranch': 'gitbranch#name'
            \ },
            \ }

" Syntastic can call a post-check hook, let's update lightline there
" For more information: :help syntastic-loclist-callback
function! SyntasticCheckHook(errors)
    call lightline#update()
endfunction

