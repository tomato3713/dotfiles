" encoding setting
set encoding=utf-8                     " バッファ内で扱う文字コード
set fileencoding=utf-8                 " 書き込み時UTF-8出力
set fileencodings=utf-8,cp932,sjis          " 読み込み時UTF-8, CP932, Shift_JISの順で自動判別
set fileformats=unix,dos,mac
set completeslash=slash

" view
set pumblend=10
set termguicolors
set noshowmode
set signcolumn=yes
set laststatus=3 " v0.7.0 and later

" editor setting
set imdisable " IM disable
set splitbelow                         " 水平分割時に下に表示
set splitright                         " 縦分割時を右に表示
set noequalalways                      " 分割時に自動調整を無効化
set smartindent                        " スマートインデントを行う
set list
set listchars=tab:>>,trail:_,nbsp:+
set ambiwidth=double
" temporary file setting
set noundofile                         " undofileを作らない
set noswapfile                         " swapfileを作らない
set nobackup
" cursor setting
set noruler                              " カーソルの位置表示
set cursorline                         " カーソルハイライト
" tab setting
set expandtab                          " tabを複数のspaceに置き換え
set tabstop=4                          " tabは半角4文字
set shiftwidth=4                       " tabの幅
set ignorecase

" set wildmenu wildmode=longest:full
set nowildmenu
set wildignore+=*.o,*.obj,*.class,*.exe,*.jpg,*.png,*.jar,*.apk,*.pdf,*.aux,*.xlsx,*.pptx,*.docs
set timeoutlen=500

" terminal mode
if has('win32') || has('win64')
    set shell=nyagos
    set shellcmdflag=-c
    set shellxquote=
    set shellxescape=
else
    set shell=zsh
endif

" set default filtype as plain text
function! s:NoneFileTypeSetTxt()
    if len(&filetype) == 0
        set filetype=txt
    endif
endfunction
autocmd BufEnter * call s:NoneFileTypeSetTxt()

function! s:remove_controll_chars(line1, line2) abort range
    let cursor = getcurpos()
    execute 'keeppattern' a:line1 ',' a:line2 's/[]//gc'
    call setpos('.', cursor)
endfunction
command! -bar -range=% RmCtlChars call s:remove_controll_chars(<line1>, <line2>)

" toggle "，/．" and "、/。"
function! s:comma_period(line1, line2) abort range
    let cursor = getcurpos()
    execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/、/，/ge'
    execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/。/．/ge'
    call setpos('.', cursor)
endfunction
command! -bar -range=% CommaPeriod call s:comma_period(<line1>, <line2>)
function! s:kutouten(line1, line2) abort range
    let cursor = getcurpos()
    execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/，/、/ge'
    execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/．/。/ge'
    call setpos('.', cursor)
endfunction
command! -bar -range=% Kutouten call s:kutouten(<line1>, <line2>)

function! s:count_chars(line1, line2) abort range
    let cursor = getcurpos()
    execute 'keepjumps keeppatterns' a:line1 ',' a:line2 's/./&/gn'
    call setpos('.', cursor)
endfunction
command! -bar -range=% CountChars call s:count_chars(<line1>, <line2>)
vmap <space>c :CountChars<CR>

" buffer
nmap <silent> <C-n> <Cmd>bnext<CR>
nmap <silent> <C-p> <Cmd>bprevious<CR>

" tab
nmap <silent> <M-n> <Cmd>tabnext<CR>
nmap <silent> <M-p> <Cmd>tabprevious<CR>

"dein Scripts-----------------------------
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
let s:dein_startup_toml = expand('~/.config/nvim/dein.toml')

" dein installation check
if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_repo_dir)
        execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    endif
    execute 'set runtimepath^=' . s:dein_repo_dir
endif

" Required:
call dein#begin(s:dein_dir)

" Let dein manage dein
" Required:
call dein#add(s:dein_repo_dir)

call dein#load_toml(s:dein_startup_toml, {'lazy': 0})

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
    call dein#install()
endif

" Clear dein cache files command
command! DeinClearCache call dein#recache_runtimepath()

set secure

