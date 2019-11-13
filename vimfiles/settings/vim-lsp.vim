let g:lsp_diagnostics_enabled = 1 " syntactic check enabled by LSP
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_auto_enable = 1
let g:lsp_use_event_queue = 1
let g:lsp_signs_enabled = 1         " enable signs
let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '!'}
let g:lsp_signs_hint = {'text': '?'}
" Opens preview windows as floating
let g:lsp_preview_float = 1
" Preview remains open and waits for an explicit call
let g:lsp_preview_autoclose = 0
" Highlight references
let g:lsp_highlight_references_enabled = 1

" autocmd BufWritePre <buffer> LspDocumentFormatSync
nnoremap <buffer> <C-k> :<C-u>LspNextError<CR>
setlocal omnifunc=lsp#complete
nnoremap <buffer> gd <plug>(lsp-definition)
nnoremap <buffer> gr <plug>(lsp-references)
nnoremap <buffer> K <plug>(lsp-hover)
nnoremap <buffer> gr <plug>(lsp-rename)

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
    augroup END
endif

if executable('typescript-language-server')
    " npm install -g typescript typescript-language-server
    " use directory with .git as root
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
    augroup END
endif
autocmd MyAutoCmd FileType ruby :setlocal isk+=@-@

" pip install python-language-server
if executable('pyls')
    autocmd MyAutoCmd User lsp_setup call lsp#register_server({
                \ 'name': 'Python',
                \ 'cmd': {server_info->['pyls']},
                \ 'whitelist': ['python'],
                \ })
endif

if executable('metals-vim')
    autocmd MyAutoCmd User lsp_setup call lsp#register_server({
                \ 'name': 'Scala',
                \ 'cmd': {server_info->['metals-vim']},
                \ 'initialization_options': { 'rootPatterns': 'build.sbt' },
                \ 'whitelist': [ 'scala', 'sbt' ],
                \ })
endif

" npm install -g dockerfile-language-server-nodejs
if executable('docker-langserver')
    autocmd MyAutoCmd User lsp_setup call lsp#register_server({
                \ 'name': 'docker-langserver',
                \ 'cmd': {server_info->[&shell, &shellcmdflag, 'docker-langserver --stdio']},
                \ 'whitelist': ['dockerfile'],
                \ })
endif

if executable('elm-language-server')
    let g:elm_setup_keybindings = 0
    autocmd MyAutoCmd User lsp_setup call lsp#register_server({
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
    autocmd MyAutoCmd BufWritePre *.elm LspDocumentFormat
endif

" other language lsp setting
if executable('efm-langserver')
    augroup LspEFM
        au!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'efm',
                    \ 'cmd': {server_info->['efm-langserver']},
                    \ 'whitelist': ['vim', 'markdown', 'yaml'],
                    \ })
    augroup END
endif
