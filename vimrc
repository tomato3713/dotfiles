"Last Change: 27/12/2017
"Maintainer: Watanabe Taichi < weasel.wt@outlook.com>

" ### Initialization ### {{{
		"My autocmd group
				augroup myautocmd
				autocmd!
				augroup END

				autocmd!

				set all&

				"condition variables

				"viとの互換ではなくvimの機能をフルに発揮できるようにする。
				set nocompatible

				" 日本語ヘルプ
				set helplang=en,ja
"}}}

" ### encoding ### {{{
		"文字コードの自動認識
		"vim自体が使用する文字エンコーディング
		set encoding=utf-8
		set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
		set fileformats=unix,dos,mac

		"保存時の文字コードを指定する

		"ファイルに保存される文字エンコーディング
		set fileencoding=utf-8

		"改行文字
		set fileformat=unix
		set ambiwidth=double "全角文字が半角で表示される問題を解消

		" must be set with multibyte strings
		scriptencoding utf-8

		"テキスト挿入中の自動折り返しを日本語に対応させる
		set formatoptions+=mM
"}}}

"### Indent ###{{{
		filetype indent on
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
		set cursorline
		"マウスとの連携機能をオフにする
		set mouse=

		filetype plugin on
		filetype on


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
		augroup templateGroup
		autocmd!
		autocmd BufNewFile *.html :0r $HOME/.vim/template/t_html.html
		autocmd BufNewFile *.tex :0r $HOME/.vim/template/t_tex.tex
		augroup END


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
		autocmd BufRead,BufNewFile *.tex :set foldmethod=marker

		"ステータスラインを表示
		set laststatus=2
		set statusline=%F%r%h%=
		set ruler " add cursor line location in right of status line

		"ファイル名内の'\'をスラッシュに置換する
		set viewoptions+=slash

		autocmd BufWritePre * call s:remove_unnecessary_space()

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

		syntax on
		set nohlsearch

				" ### terminal ### {{{
						set termguicolors
				"}}}
"}}}

" ### completion ### {{{
		"入力補完機能を有効化
				set wildmenu wildmode=list:full

				"spelling補完 on <C-x><C-s>
				set spelllang+=cjk "日本語をスペルチェックの対象 から除外する

				"dictionary Complete
				augroup DictGroup
				autocmd!
				autocmd BufRead,BufNewFile *.js :set dictionary=$HOME/.vim/dict/javascript.dict
				autocmd BufRead,BufNewFile *.html :set dictionary=$HOME/.vim/dict/html.dict
				autocmd BufRead,BufNewFile *.css :set dictionary=$HOME/.vim/dict/css.dict
				autocmd BufRead,BufNewFile *.tex :set dictionary=$HOME/.vim/dict/tex.dict
				autocmd BufRead,BufNewFile *.py :set dictionary=$HOME/.vim/dict/python.dict
				augroup END

				"Enable omni completion
				augroup OmniGroup
				autocmd!
				autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
				autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
				autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
				autocmd FileType python setlocal omnifunc=python3complete#Complete
				autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
				autocmd FileType xml setlocal omnifunc=ccomplete#Complete
				augroup END

				"syntax complete
				autocmd FileType *
				\    if &l:omnifunc == ''
				\ |    setlocal omnifunc=syntaxcomplete#Complete
				\ |  endif

" }}}

" ### Command ### {{{
		"コマンドライン補完
		set wildmenu

		"コマンドライン補完の方法
		set wildmode=longest:full,full

		"コマンド履歴の保存数
		set history=2000

		"いろんなコマンドの後にカーソルを先頭に移動させない
		set nostartofline
" }}}

" ### gui options ### {{{
		" Required:

		filetype plugin indent on
		syntax enable
" }}}

" ###vimrc### {{{
		" auto reloaed vimrc
		augroup source-vimrc
			autocmd!
			autocmd BufWritePost *vimrc source $MYVIMRC
			autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
		augroup END
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
		endfunction

		augroup AutoSyntastic
			autocmd!
			autocmd InsertLeave call s:syntastic()
		augroup END

		function! s:syntastic()
			SyntasticCheck
		endfunction

		autocmd FileType cpp call SyntasticCpp()

		function! SyntasticCpp()
				let g:syntastic_cpp_compiler="g++"
				let g:syntastic_cpp_compiler_options=" -std=c++0x"
		endfunction
		" }}}

		" neocomplete {{{
			" plugin key-mappings.
			" Enable snipMate compatibility feature.
			let g:neosnippet#enable_snipmate_compatibility = 1

			" Tell Neosnippet about the other snippets
			let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
			imap <C-k> <plug>(neosnippet_expand_or_jump)
			smap <C-k> <plug>(neosnippet_expand_or_jump)
			xmap <C-k> <plug>(neosnippet_expand_target)

			if has('conceal')
					set conceallevel=2 concealcursor=niv
			endif
		" }}}
"}}}
