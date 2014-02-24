#!/bin/sh

cd $(dirname $0)
for dotfile in .?*
do
    if [ $dotfile != '..' ] && [ $dotfile != '.git' ]
    then
        ln -Fis "$PWD/$dotfile" $HOME
    fi
done

mkdir -p $HOME/dotfiles/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim $HOME/dotfiles/.vim/bundle/neobundle.vim

git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
mkdir -p $HOME/.rbenv/plugins
git clone https://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build
