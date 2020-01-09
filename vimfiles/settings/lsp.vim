if empty(globpath(&rtp, 'plugged/vim-lsp'))
    finish
endif
if empty(globpath(&rtp, 'plugged/async.vim'))
    finish
endif
if empty(globpath(&rtp, 'plugged/asyncomplete.vim'))
    finish
endif
if empty(globpath(&rtp, 'plugged/asyncomplete-lsp.vim/'))
    finish
endif

" ### Sign Design used by LSP ###
let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '!'}
let g:lsp_signs_hint = {'text': '?'}

" ### Syntastic Check by LSP ###
let g:lsp_signs_enabled = 1           " enable signs
let g:lsp_diagnostics_enabled = 1     " syntactic check enabled
let g:lsp_diagnostics_echo_cursor = 1

" ### Completions by LSP ###
let g:lsp_text_edit_enabled = 0 " this is experimental option
let g:lsp_async_completion = 0
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_compleopt = 0
let g:asyncomplete_popup_delay = 200

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes

    autocmd BufWritePre <buffer> LspDocumentFormatSync
    " <Leader>l is prefix for vim-lsp
    nmap <Leader>l [vim-lsp]
    nnoremap <buffer> [vim-lsp]n :<C-u>LspNextError<CR>
    nnoremap <buffer> [vim-lsp]p :<C-u>LspPreviousError<CR>
    nnoremap <buffer> <C-]> :<C-u>LspDefinition<CR>
    nnoremap <buffer> gd <plug>(lsp-definition)
    nnoremap <buffer> [vim-lsp]D :<C-u>LspReferences<CR>
    nnoremap <buffer> [vim-lsp]s :<C-u>LspDocumentSymbol<CR>
    nnoremap <buffer> [vim-lsp]S :<C-u>LspWorkspaceSymbol<CR>
    nnoremap <buffer> [vim-lsp]q :<C-u>LspDocumentFormat<CR>
    vnoremap <buffer> [vim-lsp]q :LspDocumentRangeFormat<CR>
    nnoremap <buffer> [vim-lsp]k :<C-u>LspHover<CR>
    nnoremap <buffer> [vim-lsp]i :<C-u>LspImplementation<CR>
    nnoremap <buffer> [vim-lsp]r :<C-u>LspRename<CR>
    inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 |let lsp_log_file='c:/vim/src/lsp.log'


" other language lsp setting
" if executable('efm-langserver')
"     augroup LspEFM
"         autocmd!
"         autocmd User lsp_setup call lsp#register_server({
"                     \ 'name': 'efm',
"                     \ 'cmd': {server_info->['efm-langserver']},
"                     \ 'whitelist': ['vim', 'markdown', 'yaml'],
"                     \ })
"     augroup END
" endif
