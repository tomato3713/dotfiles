nmap <Leader>r [quick-run]
" <Leader>rq で QuickRun で開かれた出力バッファを閉じる
nnoremap [quick-run]q :<C-u>bw! \[QuickRun\ Output\]<CR>
nnoremap [quick-run]r :<C-u>QuickRun<CR>

let g:quickrun_config = {}

let g:quickrun_config._ = {
    \ 'outputter/buffer/split': ':botright',
    \ 'outputter/buffer/close_on_empty': 1
    \ }

" input というファイルを標準入力として与える
let g:quickrun_config.cpp = {
    \ 'command': 'g++',
    \ 'cmdopt': '-std=c++14 -Wall',
    \ 'input': 'input',
    \ }
