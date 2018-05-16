"Last Change: 27/12/2017
"Maintainer: Watanabe Taichi < weasel.wt@outlook.com>

" ### Initialization ### {{{
		"My autocmd group
		augroup MyAutoCmd
			autocmd!
		augroup END

		set all&

		"viとの互換ではなくvimの機能をフルに発揮できるようにする。
		set nocompatible

		" 日本語ヘルプ
		set helplang=en,ja

		"vim自体が使用する文字エンコーディング
		set encoding=utf-8

		" must be set with multibyte strings
		scriptencoding=utf-8

		" enable syntax higlight
		syntax on

		" enable indent plugin each filetype
		filetype plugin indent on

		" ### terminal ### {{{
				set termguicolors
		"}}}
"}}}

" ### encoding ### {{{
		"文字コードの自動認識
		set fileencodings=utf-8,utf-16,cp932,iso-2022-jp,euc-jp,sjis
		set fileformats=unix,dos,mac

		"保存時の文字コードを指定する

		"ファイルに保存される文字エンコーディング
		set fileencoding=utf-8

		"改行文字
		set fileformat=unix
		set ambiwidth=double "全角文字が半角で表示される問題を解消

		"テキスト挿入中の自動折り返しを日本語に対応させる
		set formatoptions+=mM
"}}}

" ### Indent ###{{{
		set autoindent "新しい行のインデントを継続する

		"set expandtab "tab to space
		set tabstop=4 "画面上でタブ文字の占める幅
		set shiftwidth=4 "自動インデントでずれる幅
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

		set cursorline
		"マウスとの連携機能をオフにする
		set mouse=

		"vimの無名レジスタとOSのクリップボードを連携させる
		set clipboard=unnamed

		"ファイル内容が変更されると自動読み込みする
		set autoread

		"スワップファイルを作成しない
		set noswapfile

		"undoの記録を残す
		set undofile undodir=$HOME/.vim/.vimundo

		"バックアップファイルの出力先を変更
		set nobackup
		"set backupdir=$HOME/.vim/temp

		"no viminfo file
		set viminfo+=n

		"windows上でもunix形式のend-of-lineを使う
		set viewoptions=unix

		"固定文句を入れる
		autocmd MyAutoCmd BufNewFile *.html :0r $HOME/.vim/template/t_html.html
		autocmd MyAutoCmd BufNewFile *.tex :0r $HOME/.vim/template/t_tex.tex

		set t_Co=256
		"コマンドライ=2
		set cmdheight=3

		"ステータスラインを表示
		set laststatus=2
		set statusline=%F%r%h%=
		set ruler " add cursor line location in right of status line

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
		autocmd MyAutoCmd BufRead,BufNewFile *.tex :set foldmethod=marker

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

		set nohlsearch
		set nrformats=alpha,octal,hex,bin

		" faster redraw
		set lazyredraw
		set ttyfast
"}}}

" ### completion ### {{{
		"入力補完機能を有効化
		set wildmenu wildmode=list:full

		"spelling補完 on <C-x><C-s>
		set spelllang+=cjk "日本語をスペルチェックの対象 から除外する

		"dictionary Complete
		autocmd MyAutoCmd BufRead,BufNewFile *.js :set dictionary=$HOME/.vim/dict/javascript.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.html :set dictionary=$HOME/.vim/dict/html.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.css :set dictionary=$HOME/.vim/dict/css.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.tex :set dictionary=$HOME/.vim/dict/tex.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.py :set dictionary=$HOME/.vim/dict/python.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.cpp :set dictionary=$HOME/.vim/dict/cpp.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.c :set dictionary=$HOME/.vim/dict/clang.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.rb :set dictionary=$HOME/.vim/dict/ruby.dict
		autocmd MyAutoCmd BufRead,BufNewFile *.php :set dictionary=$HOME/.vim/dict/php.dict

		"Enable omni completion
		autocmd MyAutoCmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
		autocmd MyAutoCmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
		autocmd MyAutoCmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
		autocmd MyAutoCmd FileType python setlocal omnifunc=python3complete#Complete
		autocmd MyAutoCmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
		autocmd MyAutoCmd FileType xml setlocal omnifunc=ccomplete#Complete

		"syntax complete
		autocmd MyAutoCmd FileType *
		\    if &l:omnifunc == ''
		\ |    setlocal omnifunc=syntaxcomplete#Complete
		\ |  endif

" }}}

" ### Command ### {{{
		"コマンドライン補完on
		set wildmenu

		"コマンドライン補完の方法
		set wildmode=longest:full,full

		"コマンド履歴の保存数
		set history=2000

		"いろんなコマンドの後にカーソルを先頭に移動させない
		set nostartofline

		" key mapping
		" return command line history
		cnoremap <C-n> <Down>
		" proceed commadn line history
		cnoremap <C-p> <Up>
		" Leader
		let mapleader = "\<Space>"
" }}}

" ###vimrc### {{{
	" tapping <F10> source editing vim script
	if !exists('*s:source_script')
		function s:source_script(path) abort
			let path = expand(a:path)
			if !filereadable(path)
				return
			endif
			execute 'source' fnameescape(path)
			echomsg printf(
				\ '"%s" has sourced (%s)',
				\ simplify(fnamemodify(path, ':~:.')),
				\ strftime('%c'),
				\)
		endfunction
	endif
	nnoremap <silent> <F5> :<C-u>call <SID>source_script('%')<CR>

" }}}

" ### plugin ### {{{
		" match
		set showmatch
		source $VIMRUNTIME/macros/matchit.vim " expand % command

		" tagbar.vim
		let g:tagbar_width = 30

		" syntastic.vim {{{
		set statusline+=%#warningmsg#
		set statusline+=%{SyntasticStatuslineFlag()}
		set statusline+=%*

		let g:syntastic_always_populate_loc_list = 1
		let g:syntastic_auto_loc_list = 1 " show syntastic error list
		let g:syntastic_check_on_open = 1 " run check syntastic when file open

		autocmd FileType cpp call s:SyntasticCpp()

		function! s:SyntasticCpp()
				let g:syntastic_cpp_compiler="g++"
				let g:syntastic_cpp_compiler_options=" -std=c++0x"
				let g:syntastic_cpp_compiler_options="LIBS = `pkg-config gtkmm-3.0 --cflags --libs gtk+-3.0`"
				"let g:syntastic_cpp_include_dirs=["/usr/include/gtkmm-3.0/", "/usr/include/glibmm-2.4/", "/usr/include/glibmm-2.4/glibmm/", "/usr/include/glibmm-2.4/glibmm_generate_extra_defs/"]
		endfunction
		" }}}

		" neocomplete {{{
		" plugin key-mappings.
		" Enable snipMate compatibility feature.
		let g:neosnippet#enable_snipmate_compatibility = 1

		" Tell Neosnippet about the other snippets
		let g:neosnippet#snippets_directory='~/.vim/snippets/'
		imap <C-k> <plug>(neosnippet_expand_or_jump)
		smap <C-k> <plug>(neosnippet_expand_or_jump)
		xmap <C-k> <plug>(neosnippet_expand_target)
		smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
					\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

		if has('conceal')
				set conceallevel=2 concealcursor=niv
		endif
		" }}}
		" Align.vim {{{
		let g:Align_xstrlen = 3
		" }
"}}}

set secure
