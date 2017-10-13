"Last Change: 29/09/2017
"Maintainer: Watanabe Taichi < weasel.wt@outlook.com>
"
"Initialization {{{
"My autocmd group
augroup myautocmd
  autocmd!
augroup END

"condition variables
let g:is_windows = has('win32') || has('win62')
let g:is_unix = has('unix')
let g:is_gui = has('gui_running')
let g:is_terminal = !g:is_gui

"runtimepath
set runtimepath+=$HOME/
set runtimepath+=$HOME/vimfiles/autoload/

"viとの互換ではなくvimの機能をフルに発揮できるようにする。
set nocompatible

filetype plugin on
filetype on

"Vim options {
"### Indent ###{
set autoindent "新しい行のインデントを継続する
set expandtab "tab to space
set tabstop=2 "画面上でタブ文字の占める幅
set shiftwidth =2 "自動インデントでずれる幅
set smartindent "高度なインデント
filetype indent on
"折り返しの際にインデントを考慮
if exists('+breakindent')
  set breakindent
endif
" }

"マウスとの連携機能をオフにする
set mouse=

"インクリメンタル検索を有効にする
set incsearch

"大文字小文字を無視
set ignorecase

"大文字が入力されたら大文字小文字を区別する
set smartcase
" }}}

"### Buffer ### {{{
"ファイル内容が変更されると自動読み込みする
set autoread

"スワップファイルを作成しない
set noswapfile

"undoの記録を残す
set undofile undodir=$HOME/vimfiles/.vimundo

"バックアップファイルの出力先を変更
set backup
set backupdir=$HOME/vimfiles/temp

"viminfoファイルについて指定
set viminfo+=n

"vimの無名レジスタとOSのクリップボードを連携させる
set clipboard=unnamed

"文字コードの設定 {{{
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac
set ambiwidth=double "全角文字が半角で表示される問題を解消
" must be set with multibyte strings
scriptencoding utf-8

"テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions+=mM


"固定文句を入れる
augroup templateGroup
  autocmd!
  autocmd BufNewFile *.html :0r $HOME/vimfiles/template/t_html.html
  autocmd BufNewFile *.tex :0r $HOME/vimfiles/template/t_tex.tex
augroup END
" }}}

"### View ### {
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

"不可視文字を可視化
set list

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

"windows上でもunix形式のend-of-lineを使う
set viewoptions=unix
"ファイル名内の'\'をスラッシュに置換する
set viewoptions+=slash
"}

"completion {
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
augroup END

"syntax complete
autocmd FileType *
\    if &l:omnifunc == ''
\ |    setlocal omnifunc=syntaxcomplete#Complete
\ |  endif

" }
"
" ### Command ### {
"コマンドライン補完
set wildmenu

"コマンドライン補完の方法
set wildmode=longest:full,full

"コマンド履歴の保存数
set history=2000
" }
"
" ### その他Miscellaneous ### {
" 日本語ヘルプ
set helplang=en,ja

"いろんなコマンドの後にカーソルを先頭に移動させない
set nostartofline
"}
"}
"
"gui options{
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
"}

"### plugin #### {{{
"neobundleの設定
"vim起動時にのみruntimepathにneobundle.vimを追加
if has('vim_starting')
	set nocompatible
	set runtimepath+=$HOME/vimfiles/dein/dein.vim
endif
call dein#begin(expand('$HOME/vimfiles/dein'))
"""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""
"インデントを見やすくする {{{
  call dein#add('nathanaelkane/vim-indent-guides')
  let g:indent_guides_enable_on_vim_startup=1 "起動時に自動起動
  let g:indent_guides_start_level=1 "インデントの量
  autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=#444433 ctermbg=black
  autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#333344 ctermbg=darkgray
  let g:indent_guides_guide_size=1
" }}}

"ハイライト {{{
  call dein#add('tomasr/molokai')
  colorscheme molokai
  syntax on
  set nohlsearch
  let g:molokai_original=1
  let g:rehash256=1
  set background=dark
" }}}

"autofmt日本語文章のフォーマットプラグイン
  call dein#add('vim-jp/autofmt')
  set formatexpr=autofmt#japanese#formatexpr()

  "snippet{{{
  call dein#add('Shougo/neosnippet')
  call dein#add('Shougo/neosnippet-snippets')
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
  call dein#end() 
"}}}
