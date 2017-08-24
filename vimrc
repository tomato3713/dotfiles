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

"WinではPATHに$VIMが含まれていないときにexeを見つけ出せないので修正(kaoriya)
if g:is_windows && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
  let $PATH = $VIM . ';' . $PATH
endif

"viとの互換ではなくvimの機能をフルに発揮できるようにする。
set nocompatible

"Vim options {{{
"### Indent ###{{{
set autoindent "新しい行のインデントを継続する
set expandtab "tab to space
set tabstop=2 "画面上でタブ文字の占める幅
set shiftwidth =2 "自動インデントでずれる幅
set smartindent "高度なインデント
"折り返しの際にインデントを考慮
if exists('+breakindent')
  set breakindent
endif
" }}}

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
set undofile undodir==/.vimfiles/.vimundo

"viminfoファイルについて指定
set viminfo+=n~/vimfiles/.viminfo

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

"入力補完機能を有効化
set wildmenu wildmode=list:full

"spelling補完 on <C-x><C-s>
set spelllang+=cjk "日本語をスペルチェックの対象 から除外する
set spell

" ### Command ### {{{
"コマンドライン補完
set wildmenu

"コマンドライン補完の方法
set wildmode=longest:full,full

"コマンド履歴の保存数
set history=2000
" ]}}
"
" ### その他Miscellaneous ### {{{
" 日本語ヘルプ
set helplang=ja

"いろんなコマンドの後にカーソルを先頭に移動させない
set nostartofline
"}}}
"}}}

"### plugin #### {{{
"neobundleの設定
"vim起動時にのみruntimepathにneobundle.vimを追加
if has('vim_starting')
	set nocompatible
	set runtimepath+=$VIM\bundle\neobundle.vim
endif
"neobundle.vimの初期化と設定開始
call neobundle#begin(expand('$VIM\bundle'))
if !has('vim_starting')
	".vimrcを読み込みなおしたときのための設定
	call neobundle#call_hook('on_source')
endif
"neobundle.vim自身をneobundle.vimで管理する。
"neobundle.vimを更新するための設定
NeoBundleFetch 'Shougo\neobundle.vim'

"""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""
"ここにインストールしたいプラグインの設定を書く
"  :help neobundle-examples

"現在開いているファイルをvim内で直接実行し結果を表示するプラグイン
NeoBundle 'thinca/vim-quickrun'

"インデントを見やすくする {{{
NeoBundle 'nathanaelkane/vim-indent-guides'
let g:indent_guides_enable_on_vim_startup=1 "起動時に自動起動
let g:indent_guides_start_level=1 "インデントの量
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=#444433 ctermbg=black
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#333344 ctermbg=darkgray
let g:indent_guides_guide_size=1
" }}}

"ハイライト {{{
NeoBundle 'tomasr/molokai'
colorscheme molokai
syntax on
set nohlsearch
let g:molokai_original=1
let g:rehash256=1
set background=dark
" }}}

"スニペット用のプラグイン {{{
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets' "スニペットの定義ファイル
"SurperTab like snippets behaivior
imap <expr><TAB>
    \ pumvisible() ? "\<C-n>" :
    \neosnippet#expandable_or_jumpable() ?
    \  "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
			\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
"For snippet_complete marker.
if has('conceal')
	set conceallevel=2 concealcursor=i
endif
" }}}

"インターフェースを拡張かつファイラー
NeoBundle 'Shougo/unite.vim'

"autofmt日本語文章のフォーマットプラグイン
NeoBundle 'vim-jp/autofmt'
set formatexpr=autofmt#japanese#formatexpr()

call neobundle#end()
filetype plugin indent on
" }}}
"プラグインがインストールされているかチェック
NeoBundleCheck