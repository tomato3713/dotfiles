let g:lsp_diagnostics_enabled = 1 " syntactic check enabled by LSP
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_auto_enable = 1
let g:lsp_use_event_queue = 1
let g:lsp_signs_enabled = 1         " enable signs
let g:lsp_signs_error = {'text': '✗'}
let g:lsp_signs_warning = {'text': '!!'}
let g:lsp_signs_hint = {'text': '??'}
" Opens preview windows as floating
let g:lsp_preview_float = 1
" Preview remains open and waits for an explicit call
let g:lsp_preview_autoclose = 0

" autocmd BufWritePre <buffer> LspDocumentFormatSync
nnoremap <buffer> <C-k> :<C-u>LspNextError<CR>

if executable('go-langserver')
    augroup LspGo
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'go-lang',
                    \ 'cmd': {server_info->['gopls']},
                    \ 'rootPatterns': ["go.mod", ".git/"],
                    \ 'whitelist': ['go'],
                    \ 'workspace_config': {'gopls': {'staticcheck': v:true}},
                    \ })
        autocmd FileType go setlocal omnifunc=lsp#complete
    augroup END
endif

if executable('typescript-language-server')
    Plug 'ryanolsonx/vim-lsp-javascript'

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
        autocmd FileType css,lss,sass setlocal omnifunc=lsp#complete
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
    autocmd FileType php setlocal omnifunc=lsp#complete
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
        autocmd FileType ruby setlocal omnifunc=lsp#complete
    augroup END
endif
autocmd MyAutoCmd FileType ruby :setlocal isk+=@-@

" pip install python-language-server
if executable('pyls')
Plug 'ryanolsonx/vim-lsp-python'
    autocmd MyAutoCmd User lsp_setup call lsp#register_server({
        \ 'name': 'Python',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

if executable('metals-vim')
Plug 'derekwyatt/vim-scala'
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
    Plug 'ElmCast/elm-vim', { 'for': 'elm' }
    let g:elm_setup_keybindings = 0
    autocmd MyAutoCmd User lsp_setup call lsp#register_server({
                \ 'name': 'elm-language-server',
                \ 'cmd': {server_info->[&shell, &shellcmdflag, 'elm-language-server --stdio']},
                \ 'initialization_options': {
                \ 'runtime': 'node',
                \ 'elmPath': 'elm',
                \ 'elmFormatPath': 'elm-format',
                \ 'elmTestPath': 'elm-test',
                \ 'rootPatterns': 'elm.json'
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
