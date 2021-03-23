" encoding setting
set encoding=utf-8                     " バッファ内で扱う文字コード
set fileencoding=utf-8                 " 書き込み時UTF-8出力
set fileencodings=utf-8,cp932,sjis          " 読み込み時UTF-8, CP932, Shift_JISの順で自動判別
set fileformats=unix,dos,mac

" view
set pumblend=10
set termguicolors
set noshowmode

" editor setting
set number                             " 行番号表示
set showcmd                            " 入力中のコマンドをステータスに表示
set splitbelow                         " 水平分割時に下に表示
set splitright                         " 縦分割時を右に表示
set noequalalways                      " 分割時に自動調整を無効化
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
set ignorecase

set wildmenu wildmode=longest:full
set wildignore+=*.o,*.obj,*.class,*.exe,*.jpg,*.png,*.jar,*.apk,*.pdf,*.aux,*.xlsx,*.pptx,*.docs

" terminal mode
set shell=nyagos
set shellcmdflag=-c
set shellxquote=
set shellxescape=
set shellslash

call plug#begin('~/.config/nvim/plugged')
" Language Server Protocol
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'itchyny/lightline.vim'
Plug 'plan9-for-vimspace/acme.vim'

" Plug 'tversteeg/registers.nvim'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-surround'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-repeat'
Plug 'tyru/caw.vim'
Plug 'vim-jp/autofmt'
Plug 'joshdick/onedark.vim'
Plug 'Xuyuanp/scrollbar.nvim'
call plug#end()

" ### coc.nvim ###
let g:coc_global_extensions = [
            \ 'coc-snippets'
            \, 'coc-json'
            \, 'coc-texlab'
            \, 'coc-go'
            \, 'coc-explorer'
            \, 'coc-word'
            \, 'coc-git'
            \, 'coc-clangd'
            \, 'coc-lists'
            \]
nmap <silent> <space><space> :<C-u>CocList<cr>
nmap <silent> <space>h :<C-u>call CocAction('doHover')<cr>
nmap <silent> <space>df <Plug>(coc-definition)
nmap <silent> <space>rf <Plug>(coc-references)
nmap <silent> <space>i <Plug>(coc-implementation)
nmap <silent> <space>rn <Plug>(coc-rename)
nmap <silent> <space>fmt <Plug>(coc-format)
" next or prev diagnostic
nmap <silent> <space>pd <Plug>(coc-diagnostic-prev)
nmap <silent> <space>nd <Plug>(coc-diagnostic-next)

" #### coc-snippets ####
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'
" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)
" Use <leader>x for convert visual selected code to snippet
xmap <space>x  <Plug>(coc-convert-snippet)

inoremap <silent><expr> <c-space> coc#refresh()

nmap <space>e :CocCommand explorer<CR>

" ### LightLine ###
function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

function! LightlineGitBlame() abort
  let blame = get(b:, 'coc_git_blame', '')
  " return blame
  return winwidth(0) > 120 ? blame : ''
endfunction

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'cocstatus', 'currentfunction', 'git', 'blame', 'readonly', 'filename', 'modified' ]
      \   ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'blame': 'LightlineGitBlame',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ }

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect
" Avoid showing message extra message when using completion
set shortmess+=c

autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')

" align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Caw.vim
nmap <Leader>c <plug>(caw:zeropos:toggle)
vmap <Leader>c <plug>(caw:zeropos:toggle)
"
" autofmt
set formatoptions+=mM
set formatexpr=autofmt#japanese#formatexpr() "

" scrollbar
augroup ScrollbarInit
  autocmd!
  autocmd CursorMoved,VimResized,QuitPre * silent! lua require('scrollbar').show()
  autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()
  autocmd WinLeave,FocusLost             * silent! lua require('scrollbar').clear()
augroup end

colorscheme onedark
set secure
