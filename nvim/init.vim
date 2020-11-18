" encoding setting
set encoding=utf-8                     " バッファ内で扱う文字コード
set fileencoding=utf-8                 " 書き込み時UTF-8出力
set fileencodings=utf-8,cp932,sjis          " 読み込み時UTF-8, CP932, Shift_JISの順で自動判別
set fileformats=unix,dos,mac

" editor setting
set number                             " 行番号表示
set showcmd                            " 入力中のコマンドをステータスに表示
set splitbelow                         " 水平分割時に下に表示
set splitright                         " 縦分割時を右に表示
set noequalalways                      " 分割時に自動調整を無効化
set wildmenu                           " コマンドモードの補完
set smartindent                        " スマートインデントを行う
set list
set listchars=tab:>>,trail:_,nbsp:+
" temporary file setting
set noundofile                         " undofileを作らない
set noswapfile                         " swapfileを作らない
" cursor setting
set ruler                              " カーソルの位置表示
set cursorline                         " カーソルハイライト
" tab setting
set expandtab                          " tabを複数のspaceに置き換え
set tabstop=4                          " tabは半角4文字
set shiftwidth=4                       " tabの幅

" terminal mode
set sh=nyagos

call plug#begin('~/.config/nvim/plugged')
" Language Server Protocol
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/lsp-status.nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'nathunsmitty/diagnostic-nvim'

" Snippets
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

Plug 'plan9-for-vimspace/acme.vim'
call plug#end()

" LSP config, in lua
lua require("lsp")

" Misc settings I like
let g:diagnostic_insert_delay = 1
let g:diagnostic_show_sign = 1
let g:diagnostic_enable_virtual_text = 1
" Complete parentheses for functions
let g:completion_enable_auto_paren = 0
" Work with vim-endwise
let g:completion_confirm_key = "\<C-y>"
" Set snippets source
let g:completion_enable_snippet = 'vim-vsnip'
" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect
" Avoid showing message extra message when using completion
set shortmess+=c

" autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)

function! LspStatus() abort
    if luaeval('#vim.lsp.buf_get_clients() > 0')
        return 'Lsp:' . luaeval("require('lsp-status').status()")
    endif
    return 'Lsp off'
endfunction
set statusline+=\ %{LspStatus()}

