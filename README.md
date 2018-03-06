This is my ~/.vim dir.

# Installation
clone the repogitory: `git clone --recursive https://github.com/homedm/vimfiles ~/.vim`

# update all plugin
git submodule forereach git pull
git commit -a "update: Update all vim plugin"

# add plugin
git subomdele add "github repogitory" ./pack/mypack/"start or opt"/"PluginName".vim
git commit -a "add: Add RepositoryName.vim plugin"

# Compile Option
This vimrc files don't use "python, pytho3, lua, ruby, perl option"
