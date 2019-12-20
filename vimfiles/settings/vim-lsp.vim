let g:lsp_signs_enabled = 1         " enable signs
let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '!'}
let g:lsp_signs_hint = {'text': '?'}
let g:lsp_async_completion = 0
let g:lsp_diagnostics_enabled = 1 " syntactic check enabled by LSP
let g:lsp_diagnostics_echo_cursor = 1
" Highlight references
let g:lsp_highlight_references_enabled = 1
let g:lsp_text_edit_enabled = 0

let g:lsp_auto_enable = 1
let g:lsp_use_event_queue = 1
" Opens preview windows as floating
let g:lsp_preview_float = 1
" Preview remains open and waits for an explicit call
let g:lsp_preview_autoclose = 0

command! LspDebug let lsp_log_verbose=1|let lsp_log_file='c:/vim/src/lsp.log'

function! s:set_lsp_configuration() abort
    setlocal signcolumn=yes
    autocmd BufWritePre <buffer> LspDocumentFormatSync

    setlocal omnifunc=lsp#complete

    " <Leader>l is prefix for vim-lsp
    nmap <Leader>l [vim-lsp]
    nnoremap <buffer> [vim-lsp]n :<C-u>LspNextError<CR>
    nnoremap <buffer> [vim-lsp]p :<C-u>LspPreviousError<CR>
    nnoremap <buffer> <C-]> :<C-u>LspDefinition<CR>
    nnoremap <buffer> [vim-lsp]d :<C-u>LspDefinition<CR>
    nnoremap <buffer> [vim-lsp]D :<C-u>LspReferences<CR>
    nnoremap <buffer> [vim-lsp]s :<C-u>LspDocumentSymbol<CR>
    nnoremap <buffer> [vim-lsp]S :<C-u>LspWorkspaceSymbol<CR>
    nnoremap <buffer> [vim-lsp]q :<C-u>LspDocumentFormat<CR>
    vnoremap <buffer> [vim-lsp]q :LspDocumentRangeFormat<CR>
    nnoremap <buffer> [vim-lsp]k :<C-u>LspHover<CR>
    nnoremap <buffer> [vim-lsp]i :<C-u>LspImplementation<CR>
    nnoremap <buffer> [vim-lsp]r :<C-u>LspRename<CR>
endfunction

if executable('go-langserver')
    augroup LspGo
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'go-lang',
                    \ 'cmd': {server_info->['gopls']},
                    \ 'rootPatterns': ["go.mod", ".git/"],
                    \ 'whitelist': ['go'],
                    \ 'workspace_config': {'gopls': {
                    \     'staticcheck': v:true,
                    \     'completeUnimported': v:true,
                    \     'caseSensitiveCompletion': v:true,
                    \     'usePlaceholders': v:true,
                    \     'completionDocumentation': v:true,
                    \     'watchFileChanges': v:true,
                    \     'hoverKind': 'SingleLine',
                    \ }},
                    \ })
        autocmd FileType go call s:set_lsp_configuration()
    augroup END
endif

if executable('typescript-language-server')
    " npm install -g typescript typescript-language-server
    " use directory with .git as root
    augroup LspJS
        autocmd!
        autocmd MyAutoCmd User lsp_setup call lsp#register_server({
                    \ 'name': 'javascript',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
                    \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'package.json'))},
                    \ 'whitelist': ['javascript', 'javascript.jsx'],
                    \ })
        autocmd MyAutoCmd User lsp_setup call lsp#register_server({
                    \ 'name': 'typescript',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
                    \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
                    \ 'whitelist': ['typescript', 'typescript.tsx'],
                    \ })
        autocmd FileType javascript, typescript call s:set_lsp_configuration()
    augroup END
endif

if executable('html-languageserver')
    " npm install --global vscode-html-language-server-bin
    augroup LspHTML
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'html-languageserver',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'html-languageserver --stdio']},
                    \ 'whitelist': ['html'],
                    \ })
        autocmd FileType html call s:set_lsp_configuration()
    augroup END
endif

if executable('css-languageserver')
    " npm install -g vscode-css-languageserver-bin
    augroup LspCSS
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'CSS, SCSS, LESS',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'css-languageserver --stdio']},
                    \ 'whitelist': ['css', 'less', 'sass'],
                    \ })
        autocmd FileType css, less, sass call s:set_lsp_configuration()
    augroup END
endif

" npm install -g intelephense-server
" npm list -g | head
augroup LspPHP
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'PHP',
                \ 'cmd': {server_info->['node', expand('~/.nvm/versions/node/v11.7.0/lib/node_modules/intelephense-server/lib/server.js'), '--stdio']},
                \ 'whitelist': ['php'],
                \ })
    autocmd FileType php call s:set_lsp_configuration()
augroup END

if executable('solagraph')
    " gem install solagraph
    augroup LspRuby
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'Ruby',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solagraph stdio']},
                    \ 'initialization_options': { "diagnostics": "true"},
                    \ 'whitelist': ['ruby'],
                    \ })
        autocmd FileType ruby call s:set_lsp_configuration()
    augroup END
endif
autocmd MyAutoCmd FileType ruby :setlocal isk+=@-@

" pip install python-language-server
if executable('pyls')
    augroup LspPython
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'Python',
                    \ 'cmd': {server_info->['pyls']},
                    \ 'whitelist': ['python'],
                    \ 'workspace_config': {'pyls': {'plugins': {'pydocstyle' : {'enable': v:true}}}}
                    \ })
        autocmd FileType python call s:set_lsp_configuration()
    augroup END
endif

if executable('metals-vim')
    augroup LspScala
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'Scala',
                    \ 'cmd': {server_info->['metals-vim']},
                    \ 'initialization_options': { 'rootPatterns': 'build.sbt' },
                    \ 'whitelist': [ 'scala', 'sbt' ],
                    \ })
        autocmd FileType scala call s:set_lsp_configuration()
    augroup END
endif

" npm install -g dockerfile-language-server-nodejs
if executable('docker-langserver')
    augroup LspDocker
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'docker-langserver',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'docker-langserver --stdio']},
                    \ 'whitelist': ['dockerfile'],
                    \ })
    augroup END
endif

if executable('elm-language-server')
    let g:elm_setup_keybindings = 0
    augroup LspElm
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'elm-language-server',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'elm-language-server --stdio']},
                    \ 'initialization_options': {
                    \     'runtime': 'node',
                    \     'elmPath': 'elm',
                    \     'elmFormatPath': 'elm-format',
                    \     'elmTestPath': 'elm-test',
                    \     'rootPatterns': 'elm.json'
                    \ },
                    \ 'whitelist': ['elm'],
                    \ })
        autocmd BufWritePre FileType elm LspDocumentFormat
        autocmd FileType elm call s:set_lsp_configuration()
    augroup END
endif

" Clang
if executable('clangd')
    augroup LspClang
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'clangd',
                    \ 'cmd': {server_info->['clangd']},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                    \ })
        autocmd BufWritePre FileType c LspDocumentFormat
        autocmd FileType c call s:set_lsp_configuration()
    augroup END
endif

" other language lsp setting
if executable('efm-langserver')
    augroup LspEFM
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'efm',
                    \ 'cmd': {server_info->['efm-langserver']},
                    \ 'whitelist': ['vim', 'markdown', 'yaml'],
                    \ })
    augroup END
endif
