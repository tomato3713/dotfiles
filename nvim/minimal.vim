set nocompatible
set wildmode=full

" --- add runtimepath ---
set runtimepath+=~/repos/github.com/denops.vim

" --- load plugins ---
" テスト対象のPluginをロードする
" set runtimepath+=~/repos/dps-joplin

" source ~/repos/github.com/denops.vim/plugin/denops.vim
" source ~/repos/github.com/tomato3713/dps-joplin/plugin/joplin.vim
" --- 追加設定 ---
" Vimのファイルタイプ検出,ファイルタイププラグインとインデントプラグインをオンにする設定
filetype plugin indent on

" --- denopsの設定 ---
" Denoの起動時型チェックを有効化(開発が安定したら明示指定を削除する
" let g:denops#server#service#deno_args = [
"       \ '-q',
"       \ '--unstable',
"       \ '-A',
"       \ ]

