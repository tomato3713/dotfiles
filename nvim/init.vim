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

" editor setting
set imdisable " IM disable
set number                             " 行番号表示
set splitbelow                         " 水平分割時に下に表示
set splitright                         " 縦分割時を右に表示
set noequalalways                      " 分割時に自動調整を無効化
set smartindent                        " スマートインデントを行う
set list
set listchars=tab:>>,trail:_,nbsp:+
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

set wildmenu wildmode=longest:full
set wildignore+=*.o,*.obj,*.class,*.exe,*.jpg,*.png,*.jar,*.apk,*.pdf,*.aux,*.xlsx,*.pptx,*.docs
set timeoutlen=500

" terminal mode
set shell=nyagos
set shellcmdflag=-c
set shellxquote=
set shellxescape=

" set default filtype as plain text
function! s:NoneFileTypeSetTxt()
    if len(&filetype) == 0
        set filetype=txt
    endif
endfunction
autocmd BufEnter * call s:NoneFileTypeSetTxt()

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

call plug#begin('~/.config/nvim/plugged')
" Language Server Protocol
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'liuchengxu/vista.vim'
Plug 'lambdalisue/gina.vim'

" extend feature
Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'voldikss/vim-floaterm'
Plug 'tpope/vim-surround'
" Plug 'tversteeg/registers.nvim'

" edit
Plug 'junegunn/vim-easy-align'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-repeat'
Plug 'tyru/caw.vim'
Plug 'vim-jp/autofmt'
Plug 'tyru/eskk.vim'
" Plug 'moorereason/vim-markdownfmt'

" view
Plug 'Xuyuanp/scrollbar.nvim'
Plug 'wellle/context.vim'
Plug 'itchyny/lightline.vim'
Plug 'joshdick/onedark.vim'

" File Explorer
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/fern-hijack.vim'

" for forgotting how to do
Plug 'folke/which-key.nvim'

" other
Plug 'skanehira/translate.vim'
Plug 'plan9-for-vimspace/acme.vim'
Plug 'skanehira/code2img.vim'

" Game
Plug 'alec-gibson/nvim-tetris'
Plug 'seandewar/nvimesweeper'
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
            \, 'coc-pairs'
            \, 'coc-project'
            \, 'coc-markdownlint'
            \]

nmap <silent> <space><space> :<C-u>CocList<cr>
nmap <silent> <space>p :CocList project<CR>
nmap <silent> <space>o :CocList outline<CR>
nmap <silent> <space>s :CocList symbols<CR>
nmap <silent> <space>rn <Plug>(coc-rename)
nmap <silent> <space>fmt <Plug>(coc-format)
command! -nargs=0 Format :call CocAction('format')
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" show documentation in preview window.
nmap <silent> <space>h :call <SID>show_documentation()<CR>
function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
endfunction

" goto
nmap <silent> <space>df <Plug>(coc-definition)
nmap <silent> <space>rf <Plug>(coc-references)
nmap <silent> <space>i <Plug>(coc-implementation)
nmap <silent> <space>t <Plug>(coc-type-definition)
" next or prev diagnostic
nmap <silent> <space>dp <Plug>(coc-diagnostic-prev)
nmap <silent> <space>dn <Plug>(coc-diagnostic-next)

" Applying codeAction to the selected region.
" Example: `<space>aap` for current paragraph
xmap <space>a  <Plug>(coc-codeaction-selected)
nmap <space>a  <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <space>ac  <Plug>(coc-codeaction)

" apply autofix to problem on the current line
nmap <space>qf <Plug>(coc-fix-current)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" #### coc-snippets ####
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-k> for select text for visual placeholder of snippet.
vmap <C-k> <Plug>(coc-snippets-select)
" Use <C-p> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-p>'
" Use <C-n> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-n>'
" Use <C-n> for both expand and jump (make expand higher priority.)
imap <C-n> <Plug>(coc-snippets-expand-jump)
" Use <leader>x for convert visual selected code to snippet
xmap <space>x  <Plug>(coc-convert-snippet)
inoremap <silent><expr> <C-y> pumvisible() ? coc#_select_confirm() : coc#refresh()

nmap <space>e :CocCommand explorer<CR>
nmap <space>c :CocCommand<CR>

" #### coc-git ####
" navigate chunks of current buffer
nmap [g <Plug>(coc-git-prevchunk)
nmap ]g <Plug>(coc-git-nextchunk)
" navigate conflicts of current buffer
nmap [c <Plug>(coc-git-prevconflict)
nmap ]c <Plug>(coc-git-nextconflict)
" show chunk diff at current position
nmap gs <Plug>(coc-git-chunkinfo)
" show commit contains current position
nmap gc <Plug>(coc-git-commit)
" create text object for git chunks
omap ig <Plug>(coc-git-chunk-inner)
xmap ig <Plug>(coc-git-chunk-inner)
omap ag <Plug>(coc-git-chunk-outer)
xmap ag <Plug>(coc-git-chunk-outer)

" ### Vista.vim ###
nmap <space>v :Vista coc<CR>

" ### LightLine ###
function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

function! LightlineGitBlame() abort
    let blame = get(b:, 'coc_git_blame', '')
    " return blame
    return winwidth(0) > 120 ? blame : ''
endfunction

function L_eskk_get_mode()
    if (mode() == 'i') && eskk#is_enabled()
        return g:eskk#statusline()
    else
        return ''
    endif
endfunction

function! NearestMethodOrFunction() abort
    return get(b:, 'vista_nearest_method_or_function', '')
endfunction

" By default vista.vim never run if you don't call it explicitly.
"
" If you want to show the nearest function in your statusline automatically,
" you can add the following line to your vimrc
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [
      \     [ 'eskk' ],
      \     [ 'mode', 'paste' ],
      \     [ 'filename' ],
      \     [ 'method' ],
      \     [ 'cocstatus', 'git', 'blame', 'readonly', 'modified' ]
      \   ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'blame': 'LightlineGitBlame',
      \   'currentfunction': 'CocCurrentFunction',
      \   'eskk': 'L_eskk_get_mode',
      \   'method': 'NearestMethodOrFunction'
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

" eskk.vim
if empty(globpath(&rtp, 'plugged/eskk.vim')) || empty('$HOME/.config/skk')
    finish
else
    let g:eskk#enable_completion = 0
    let g:eskk#fix_extra_okuri = 0
    let g:eskk#marker_henkan = ";"
    let g:eskk#marker_henkan_select = ">>"
    let g:eskk#marker_okuri = "*"
    let g:eskk#marker_jisyo_touroku = "?"
    let g:eskk#set_undo_point = {
                \	'sticky': 1,
                \	'kakutei': 0,
                \}
    let g:eskk#directory = "~/.config/skk"
    let g:eskk#dictionary = { 'path': "~/.config/skk/user-dict", 'sorted': 0, 'encoding': 'utf-8', }
    let g:eskk#large_dictionary = { 'path': "~/.config/skk/SKK-JISYO.L", 'sorted': 1, 'encoding': 'euc-jp', }
    " autocmd VimEnter * imap <C-j> <Plug>(eskk:toggle)
    " autocmd VimEnter * cmap <C-j> <Plug>(eskk:toggle)
    function! s:eskk_initial_pre()
        let t = eskk#table#new('rom_to_hira*', 'rom_to_hira')
        call t.add_map(',', '，')
        call t.add_map('.', '．')
        call eskk#register_mode_table('hira', t)
        let t = eskk#table#new('rom_to_kata*', 'rom_to_kata')
        call t.add_map(',', '，')
        call t.add_map('.', '．')
        call eskk#register_mode_table('kata', t)
    endfunction
    autocmd User eskk-initialize-pre call s:eskk_initial_pre()
    " sticky shift
    " function! s:eskk_initial_post() abort
    "     EskkUnmap -type=sticky Q
    "     EskkMap -type=sticky ;
    " endfunction
    " autocmd User eskk-initialize-post call s:eskk_initial_post()
    " toggle sticky SKK
    let g:toggle_sticky_skk = 0
    function! s:sticky_skk_toggle() abort
        let g:toggle_sticky_skk = g:toggle_sticky_skk == 1 ? 0 : 1
        if g:toggle_sticky_skk ==# 1
            echomsg 'Sticky SKK ON'
        else
            echomsg 'Sticky SKK OFF'
        endif
    endfunction
    function! s:eskk_on() abort
        if g:toggle_sticky_skk ==# 1
            call eskk#enable()
        endif
    endfunction
    augroup sticky_skk
        autocmd!
        autocmd InsertEnter * call s:eskk_on()
        autocmd User eskk-enable-post lmap <buffer> l <Plug>(eskk:disable)
    augroup END
    command! -nargs=0 StickySKKToggle call s:sticky_skk_toggle()
endif

" scrollbar
if !empty(globpath(&rtp, 'plugged/scrollbar.nvim'))
    augroup ScrollbarInit
        autocmd!
        autocmd CursorMoved,VimResized,QuitPre * silent! lua require('scrollbar').show()
        autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()
        autocmd WinLeave,BufLeave,BufWinLeave,FocusLost * silent! lua require('scrollbar').clear()
    augroup end
end

" Fern
let g:fern#renderer = 'nerdfont'
nnoremap <silent> <Leader>e :Fern . <CR>

" translation.vim
let g:translate_target = 'ja'
let g:translate_popup_window = 0
let g:translate_winsize = 5
vmap t <Plug>(VTranslate)

" which-key.nvim
if !empty(globpath(&rtp, 'plugged/which-key.nvim'))
    lua require("which-key").setup {}
endif

" wilder.nvim
call wilder#setup({
            \ 'modes': [':', '/', '?'],
            \ 'next_key': '<C-n>',
            \ 'previous_key': '<C-p>',
            \ 'accept_key': '<C-y>',
            \ 'reject_key': '<C-e>',
            \ })

" floaterm.nvim & terminal
noremap <A-t>n :FloatermNew<CR>
noremap <A-t>s :FloatermShow<CR>
tnoremap <A-t>h <C-\><C-n>:FloatermHide<CR>
tnoremap <A-t>w <C-\><C-n><C-w><C-w>

colorscheme onedark
set secure
