git config --global alias.s status
git config --global alias.d diff
git config --global alias.b branch
git config --global alias.l 'log --oneline --graph'
git config --global alias.a add
git config --global alias.ignore '!gi() { curl -L -s https://www.gitignore.io/api/$@ ;}; gi'

# vimdiff
git config --global diff.tool vimdiff
git config --global difftool.prompt false
git config --global merge.tool vimdiff
git config --global mergetool.prompt false
git config --global merge.conflictstyle diff3
