"Last Change: 06/10/2018
"Maintainer: Watanabe Taichi <weasel.wt(at)outlook.com>

" ### Initialization ### {{{
" My autocmd group
augroup MyAutoCmd
        autocmd!
augroup END

set all&

" Make it fully functional with vim, not compatible with vi.
set nocompatible

" in shell setting file, for example .bashrc or .cshrc
" setenv $VIMRUNTIME ~/vim/vim/runtime

" japanese help
set helplang=en,ja

"vim自体が使用する文字エンコーディング
set encoding=utf-8

" must be set with multibyte strings
scriptencoding=utf-8

" enable syntax higlight
set synmaxcol=200
syntax on

" disable indent plugin each filetype
filetype plugin indent off

" ### terminal ### {{{
if has('terminal')
        set termguicolors
endif
"}}}
"}}}

" ### encoding ### {{{
" 文字コードの自動認識
set fileencodings=utf-8,utf-16,cp932,iso-2022-jp,euc-jp,sjis
set fileformats=unix,dos,mac
autocmd MyAutoCmd BufEnter * setlocal bomb?

"ファイルに保存される文字エンコーディング
set fileencoding=utf-8

"改行文字
set fileformat=unix
set ambiwidth=double "全角文字が半角で表示される問題を解消

" テキスト挿入中の自動折り返しを日本語に対応させる
" auto commet off
augroup auto_comment__off
        autocmd!
        autocmd BufEnter * setlocal formatoptions=tcqmM
augroup END
"}}}

" ### Indent ###{{{
set autoindent "新しい行のインデントを継続する

set expandtab "tab to space
set tabstop=4 "画面上でタブ文字の占める幅
"set shiftwidth=4 "自動インデントでずれる幅
set smartindent "高度なインデント

"折り返しの際にインデントを考慮
if exists('+breakindent')
        set breakindent
endif
" }}}

" ### search ### {{{
"インクリメンタル検索を有効にする
set incsearch

"大文字小文字を無視
set ignorecase

"大文字が入力されたら大文字小文字を区別する
set smartcase
" }}}

" ### Buffer ### {{{
" if miss to guess filetype
autocmd MyAutoCmd BufWritePost *
                        \ if &filetype ==# '' && exists('b:ftdetect') |
                        \ unlet! b:ftdetect |
                        \ filetype detect |
                        \ endif


" Enable cursorline at needed
augroup vimrc-auto-cursorline
        autocmd!
        autocmd CursorMoved,CursorMovedI * call s:auto_cursorline('CursorMoved')
        autocmd CursorHold,CursorHoldI * call s:auto_cursorline('CursorHold')
        autocmd WinEnter * call s:auto_cursorline('WinEnter')
        autocmd WinLeave * call s:auto_cursorline('WinLeave')

        let s:cursorline_lock = 0
        function! s:auto_cursorline(event)
                if a:event ==# 'WinEnter'
                        setlocal cursorline
                        let s:cursorline_lock = 2
                elseif a:event ==# 'WinLeave'
                        setlocal nocursorline
                elseif a:event ==# 'CursorMoved'
                        if s:cursorline_lock
                                if 1 < s:cursorline_lock
                                        let s:cursorline_lock = 1
                                else
                                        setlocal nocursorline
                                        let s:cursorline_lock = 0
                                endif
                        endif
                elseif a:event ==# 'CursorHold'
                        setlocal cursorline
                        let s:cursorline_lock = 1
                endif
        endfunction
augroup END

"マウスとの連携機能をオフにする
set mouse=

"vimの無名レジスタとOSのクリップボードを連携させる
if has('clipboard')
        set clipboard=unnamed
endif

"ファイル内容が変更されると自動読み込みする
set autoread
autocmd MyAutoCmd WinEnter * checktime

"スワップファイルを作成しない
set noswapfile

"undoの記録を残す
set undofile undodir=$HOME/.vim/.vimundo

"バックアップファイルの出力先を変更
set nobackup
"set backupdir=$HOME/.vim/temp

"no viminfo file
set viminfo=

"windows上でもunix形式のend-of-lineを使う
set viewoptions=unix

set t_Co=256

set cmdheight=2

"ステータスラインを表示
set laststatus=2
set statusline=%F%r%h%=
set ruler " add cursor line location in right of status line

" title
set title

"不可視文字を不可視化
set nolist

"最低でも上下に表示する行数
set scrolloff=5

"入力したコマンドを画面下に表示
set showcmd

"自動折り返ししない
set textwidth=0

"長い行を@にさせない
set display=lastline

" disable conceal for tex
let g:tex_conceal=''
autocmd MyAutoCmd FileType latex :setlocal foldmethod=marker

"ステータスラインを表示
set laststatus=2
set statusline=%F%r%h%=
set ruler " add cursor line location in right of status line

"ファイル名内の'\'をスラッシュに置換する
set viewoptions+=slash

autocmd MyAutoCmd BufWritePre * call s:remove_unnecessary_space()

function! s:remove_unnecessary_space()
        " delete last spaces
        %s/\s\+$//ge

        " delete last blank lines
        while getline('$') == ""
                $delete _
        endwhile
endfunction


"colorscheme
colorscheme iceberg
autocmd MyAutoCmd FileType help call s:set_japanese_document_format()

function! s:set_japanese_document_format()
        " change important keyword the last of lines ' >' and the top of lines '<'
        if &buftype != 'help'
                hi ignore ctermfg=red
                if has('conceal')
                        setlocal conceallevel=0
                endif
        endif
endfunction

set nohlsearch
if v:version > 800
        set nrformats=alpha,hex,bin
endif

" faster redraw
set lazyredraw
set ttyfast
"}}}

" ### Diff ### {{{
set diffexpr=MyDiff()
function! MyDiff()
        let opt = ""
        if &diffopt =~ "icase"
                let opt = opt . "-i "
        endif
        if &diffopt =~ "iwhile"
                let opt = opt . "-b "
        endif
        silent execute "!diff -a --binary " . opt . v:fname_in . " " . v:fname_new . " > " . v:fname_out
endfunction
" }}}

" ### completion ### {{{
"入力補完機能を有効化
set wildmenu wildmode=list:full

"spelling補完 on <C-x><C-s>
set spelllang+=cjk "日本語をスペルチェックの対象 から除外する

"dictionary Complete
augroup dict-comp
        autocmd!
        autocmd FileType javascript :setlocal dictionary=$HOME/.vim/dict/javascript.dict
        autocmd FileType html :setlocal dictionary=$HOME/.vim/dict/html.dict
        autocmd FileType css :setlocal dictionary=$HOME/.vim/dict/css.dict
        autocmd FileType latex :setlocal dictionary=$HOME/.vim/dict/tex.dict
        autocmd FileType python :setlocal dictionary=$HOME/.vim/dict/python.dict
        autocmd FileType cpp :setlocal dictionary=$HOME/.vim/dict/cpp.dict
        autocmd FileType c :setlocal dictionary=$HOME/.vim/dict/clang.dict
        autocmd FileType ruby :setlocal dictionary=$HOME/.vim/dict/ruby.dict
        autocmd FileType php :setlocal dictionary=$HOME/.vim/dict/php.dict
augroup END

"Enable omni completion
augroup omni-comp
        autocmd!
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python setlocal omnifunc=python3complete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
        autocmd FileType xml setlocal omnifunc=ccomplete#Complete
augroup END

"syntax complete
autocmd MyAutoCmd FileType *
                        \    if &l:omnifunc == ''
                        \ |    setlocal omnifunc=syntaxcomplete#Complete
                        \ |  endif

" }}}

" ### Command ### {{{
" set command line completion
set wildmenu

" コマンドライン補完の方法
set wildmode=longest:full,full

" the count of command history
set history=2000

" いろんなコマンドの後にカーソルを先頭に移動させない
set nostartofline

" key mapping
" Wait key time
set timeout ttimeoutlen=50
" change Leader key to Space key
let mapleader = "\<Space>"

" Load current file as vimrc
nnoremap <silent> <F5> :<C-u>call <SID>source_script('%')<CR>

" return command line history
cnoremap <C-n> <Down>
" proceed commadn line history
cnoremap <C-p> <Up>
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
" disable not to save and close
nnoremap ZQ <Nop>

" when tap :wq, make not save and close if buffer is no difference before
cnoremap wq x

" }}}

" ### Load local vimrc ### {{{
augroup vimrc-local
	autocmd!
	autocmd BufNewFile,BufRead * call s:vimrc_local(expand('<afile>:p:h'))
augroup END

function! s:vimrc_local(loc)
	let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
	for i in reverse(filter(files, 'filereadable(v:val)'))
		source `=i`
	endfor
endfunction
" }}}

" ### Ruby setting ### {{{
autocmd MyAutoCmd FileType ruby :setlocal isk+=@-@
" }}}

" ### Golang setting ### {{{
if( &filetype == 'go' )
        " setting of runtimepath
        set runtimepath+=$GOROOT/misc/vim
        let g:go_bin_path = $GOPATH.'/bin'
        " for completion
        exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
        set runtimepath+=$GOPATH/src/github.com/nsf/gocode/vim
        set completeopt=menu,preview
endif
" }}}

" ### plugin ### {{{
" match {{{
let g:loaded_matchparen = 1
set showmatch
set matchpairs+=「:」,（:）
" expand % command
if has('packages')
        packadd! matchit " if has package function, read /pack/.../matchit.vim
else
        runtime! macros/matchit.vim
endif
" }}}

" tagbar.vim
let g:tagbar_width = 30

" code checker plugin
" ale {{{
if has('job') && has('channel') && has('timers')
        let g:ale_sign_column_always = 1
        let g:ale_list_window_size = 3

        " format message
        let g:ale_echo_msg_error_str = 'E'
        let g:ale_echo_msg_warning_str = 'W'
        let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

        "move error mapping
        nmap <silent> <C-k> <plug>(ale_next_wrap)

        " check at :w
        let g:ale_lint_on_save = 0
        let g:ale_lint_on_text_changed = 'never'
        "check at open file
        " Disable check at file open
        let g:ale_lint_on_enter = 0

        " use QuickFix instead of location list
        let g:ale_set_loclist = 0
        let g:ale_set_quickfix = 1

        " set linter
        let g:ale_linters = {
                                \ 'javascript' : ['eslint'],
                                \ 'html' : ['cHTMLHint'],
                                \ 'css' : ['csslint'],
                                \ 'latex' : ['chktex'],
                                \ 'c' : ['gcc'],
                                \ 'cpp' : ['gcc'],
                                \ }
        autocmd MyAutoCmd BufNewFile,BufRead *.cpp call s:cpplinter()
        autocmd MyAutoCmd BufNewFile,BufRead *.c call s:clanglinter()

        function! s:cpplinter()
                let g:ale_cpp_gcc_options="-std=c++17 -Wall"
        endfunction

        function! s:clanglinter()
                let g:ale_c_gcc_options="-std=c99 -Wall"
        endfunction

        " set fixer
        nmap <space>= :ALEFix<CR>
endif
" }}}

" neocomplete {{{
" plugin key-mappings.
if v:version > 704
        " Enable snipMate compatibility feature.
        let g:neosnippet#enable_snipmate_compatibility = 1

        " Tell Neosnippet about the snippets directory
        let g:neosnippet#snippets_directory=[]
        " My snippets files
        let g:neosnippet#snippets_directory+=['~/.vim/snippets/']
        " Plugin snippets files
        let g:neosnippet#snippets_directory+=['~/.vim/pack/mypack/start/neosnippet-snippets.vim/neosnippets/']
        " set key map for snippet
        imap <C-k> <plug>(neosnippet_expand_or_jump)
        smap <C-k> <plug>(neosnippet_expand_or_jump)
        xmap <C-k> <plug>(neosnippet_expand_target)
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                                \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

        if has('conceal')
                set conceallevel=2 concealcursor=niv
        endif
endif
" }}}
" Align.vim {{{
" Setting for japanese environment
let g:Align_xstrlen = 3
" }
"}}}

" enable indent plugin each filetype
filetype plugin indent off
set secure
