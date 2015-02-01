#!/bin/bash

DOT_FILES=(.zshrc .vim .vimrc .tmux .tmux.conf .gitconfig .gemrc)
RCFILE=(.${SHELL}rc)

for file in ${DOT_FILES[@]}
do
  ln -s $HOME/dotfiles/$file $HOME/$file
done

mkdir -p $HOME/dotfiles/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim $HOME/dotfiles/.vim/bundle/neobundle.vim

cd $HOME/dotfiles/.vim/bundle
rmdir *

echo "install rbenv? (yes/no)"
read rbenv

case "${rbenv}" in
	yes)
	git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
	mkdir -p $HOME/.rbenv/plugins
	git clone https://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build
	;;
*)
	;;
esac

# rbenv PATH
CHECKrbenv=`grep "rbenv init -"  ${HOME}/${RCFILE}`

if [ "CHECKrbenv" != "rbenv init -" ]; then
  echo "" >> ${RCFILE}
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ${HOME}/${RCFILE}
  echo 'eval "$(rbenv init -)"' >> ${HOME}/${RCFILE}
fi
