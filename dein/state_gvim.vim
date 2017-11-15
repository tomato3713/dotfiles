if g:dein#_cache_version != 100 | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['c:/Users/taichi/vimfiles/vimrc'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = 'c:/Users/taichi/vimfiles/dein'
let g:dein#_runtime_path = 'c:/Users/taichi/vimfiles/dein/.cache/vimrc/.dein'
let g:dein#_cache_path = 'c:/Users/taichi/vimfiles/dein/.cache/vimrc'
let &runtimepath = 'c:\Users\taichi/vimfiles,C:\prog\vim\gvim.exe/vimfiles,c:/Users/taichi/vimfiles/dein/repos/github.com/Shougo/dein.vim,c:/Users/taichi/vimfiles/dein/.cache/vimrc/.dein,C:\Users\taichi\vimfiles,c:/Users/taichi/vimfiles/dein/.cache/vimrc/.dein/after,C:\prog\vim\gvim.exe/vimfiles/after,c:\Users\taichi/vimfiles/after,c:\Users\taichi/,c:\Users\taichi/vimfiles/autoload/,c:\Users\taichi/vimfiles/dein/repos/github.com/Shougo/dein.vim,c:\Users\taichi/vimfiles/dein/Required/github.com'
filetype off
