"Last Change: 29/10/2017
"Maintainer: Watanabe Taichi < weasel.wt@outlook.com>
"
"Initialization {{{
"My autocmd group
augroup myautocmd
  autocmd!
augroup END

autocmd!

set all&

"condition variables
let g:is_windows = has('win32') || has('win62')
let g:is_unix = has('unix')
let g:is_gui = has('gui_running')
let g:is_terminal = !g:is_gui

"runtimepath
set runtimepath+=$HOME/
set runtimepath+=$HOME/vimfiles/autoload/

"viとの互換ではなくvimの機能をフルに発揮できるようにする。set nocompatible

" 日本語ヘルプ
set helplang=en,ja
"}}}

"文字コードの設定 {{{
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

filetype plugin on
filetype on


"### Indent ###{{{
filetype indent on
set autoindent "新しい行のインデントを継続する
"set expandtab "tab to space
set tabstop=2 "画面上でタブ文字の占める幅
set shiftwidth =2 "自動インデントでずれる幅
set smartindent "高度なインデント
"折り返しの際にインデントを考慮
if exists('+breakindent')
  set breakindent
endif
" }}}

"search{{{
"インクリメンタル検索を有効にする
set incsearch

"大文字小文字を無視
set ignorecase

"大文字が入力されたら大文字小文字を区別する
set smartcase
" }}}

"### Buffer ### {{{
"マウスとの連携機能をオフにする
set mouse=

"vimの無名レジスタとOSのクリップボードを連携させる
set clipboard=unnamed

"ファイル内容が変更されると自動読み込みする
set autoread

"スワップファイルを作成しない
set noswapfile

"undoの記録を残す
set undofile undodir=$HOME/vimfiles/.vimundo

"バックアップファイルの出力先を変更
set nobackup
"set backupdir=$HOME/vimfiles/temp

"no viminfo file
set viminfo+=n

"windows上でもunix形式のend-of-lineを使う
set viewoptions=unix

"固定文句を入れる
augroup templateGroup
  autocmd!
  autocmd BufNewFile *.html :0r $HOME/vimfiles/template/t_html.html
  autocmd BufNewFile *.tex :0r $HOME/vimfiles/template/t_tex.tex
augroup END
" }}}

"### View ### {{{
"色数
set t_Co=256
"コマンドラインの行数
set cmdheight=3

"現在行の色をかえる
set cursorline
let g:cursorline_flg=1 "cursorlineはウィンドウローカルなのでグローバルなフラグを用意しておく
let g:cursorcolumn_flg=0

"ステータスラインを表示
set laststatus=2
set statusline=%F%r%h%=

"不可視文字を不可視化
set nolist

"相対的な行番号を表示
set number relativenumber

"最低でも上下に表示する行数
set scrolloff=5

"入力したコマンドを画面下に表示
set showcmd

"自動折り返ししない
set textwidth=0

"タブページのラベルを常に表示
set showtabline=2

"長い行を@にさせない
set display=lastline

"ファイル名内の'\'をスラッシュに置換する
set viewoptions+=slash
"
"colorscheme
set background=dark
colorscheme iceberg

syntax on
set nohlsearch
"}}}

" folding {{{
set foldmethod=marker
set foldlevel=0

augroup TexFoldingGroup
  autocmd!
  autocmd BufRead, BufNewFile *.tex setlocal foldmethod=indent | setlocal foldlevel=2
augroup END
"}}}

"completion {{{
"入力補完機能を有効化
set wildmenu wildmode=list:full

"spelling補完 on <C-x><C-s>
set spelllang+=cjk "日本語をスペルチェックの対象 から除外する

"dictionary Complete
augroup DictGroup
  autocmd!
  autocmd BufRead,BufNewFile *.js :set dictionary=$HOME/vimfiles/dict/javascript.dict
  autocmd BufRead,BufNewFile *.html :set dictionary=$HOME/vimfiles/dict/html.dict
  autocmd BufRead,BufNewFile *.css :set dictionary=$HOME/vimfiles/dict/css.dict
  autocmd BufRead,BufNewFile *.tex :set dictionary=$HOME/vimfiles/dict/tex.dict
  autocmd BufRead,BufNewFile *.py :set dictionary=$HOME/vimfiles/dict/python.dict
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

"tex compile key map
"

" }}}

"gui options{{{
"menuを使わない
set winaltkeys=yes
set guioptions=MRr

"ウィンドウの幅
set columns=100
"ウィンドウの高さ
set lines=50

"挿入モード、検索モードでのデフォルトのIME状態の設定
set iminsert=0
set imsearch=0
"}}}

"### plugin #### {{{
" Required:
set runtimepath+=$HOME/vimfiles/dein/repos/github.com/Shougo/dein.vim
set runtimepath+=$HOME/vimfiles/dein/Required/github.com

" Required:
if dein#load_state('$HOME/vimfiles/dein')
  call dein#begin('$HOME/vimfiles/dein')

  " Let dein manage dein
  " Required:
  call dein#add('$HOME/vimfiles/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
	call dein#add('nathanaelkane/vim-indent-guides')
	call dein#add('tomasr/molokai')
	call dein#add('w0ng/vim-hybrid')
	call dein#add('cocopon/iceberg.vim')
	call dein#add('thinca/vim-quickrun')
	call dein#add('vim-jp/autofmt')
	call dein#add('Shougo/neosnippet')
	call dein#add('Shougo/neosnippet-snippets')

	" You can specify revision/branch/tag.
	call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

	" Required:
	call dein#end()
	call dein#save_state()
	endif

	" Required:
	filetype plugin indent on
	syntax enable

	" If you want to install not installed plugins on startup.
	"if dein#check_install()
	"  call dein#install()
	"endif

	"""""""""""""""""""""""""""""""""""""""""""""""
	"""""""""""""""""""""""""""""""""""""""""""""""
	"インデントを見やすくする vim-indent-guides {{{
		let g:indent_guides_enable_on_vim_startup=1 "起動時に自動起動
			let g:indent_guides_start_level=1 "インデントの量
			autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=#444433 ctermbg=black
			autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#333344 ctermbg=darkgray
			let g:indent_guides_guide_size=1
			" }}}

"colorscheme molokai {{{
	"let g:molokai_original=1
		"let g:rehash256=1
		" }}}

"autofmt日本語文章のフォーマットプラグイン{{{
	set formatexpr=autofmt#japanese#formatexpr()
		"}}}

"snippet{{{
	"Plugin key-mappings.
		imap <C-k> <Plug>(neosnippet_expand_or_jump)
		smap <C-k> <Plug>(neosnippet_expand_or_jump)
		xmap <C-k> <Plug>(neosnippet_expand_target)
		"SuperTab like snippets behabior.
		imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
		\ "\<Plug>(neosnippet_expand_or_jump)"
		\: pumvisible() ? "\<C-n>" : "\<TAB>"
		smap <expr><TAB> neosnippet#expandable_or_jumpable) ?
		\ "\<Plug>(neosnippet_expand_or_jump)"
		\: "_<TAB>"
		"For snippet_complete marker.
		if has('conceal')
			set conceallevel=2 concealcursor=i
				endif
				"}}}
"
	"quickrun {{{
		"成功時はbufferに、失敗時はquickfixに出力するlet g:quickrun_config = get(g:, 'quickrun_config', {})
			let g:quickrun_config = {
				\ 'runner'    : 'vimproc',
				\ 'runner/vimproc/updatetime' : 60,
				\ 'outputter' : 'error',
				\ 'outputter/error/success' : 'buffer',
				\ 'outputter/error/error'   : 'quickfix',
				\ 'outputter/buffer/split'  : ':rightbelow 8sp',
				\ 'outputter/buffer/close_on_empty' : 1,
				\ }

		"qでquickfixを閉じられるようにする
			au FileType qf nnoremap <silent><buffer>q :quit<CR>
			"}}}

"}}}

"vimrc {{{
	" auto reloaed vimrc
		augroup source-vimrc
		autocmd!
		autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
		autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
		augroup END
		" }}}
