#!/bin/bash

set -eux
if [ ${CI} == "true" ]; then
  set +e
fi

# update Homebrew
brew update
brew upgrade

# shell
brew install zsh

# Utilities
brew install openssl
brew install libyaml
brew install readline
brew install anyenv

# git
brew install git

#font
#brew tap sanemat/font
#install ricty --powerline

#tools
brew install tmux
brew install nkf
brew install vim 
brew install nvim
brew install w3m
brew install curl
brew install wget
brew install tree
brew install nmap

# dev
brew install go
# brew tap peco/peco
# brew install peco
brew install kubectl
brew install gpg2
brew install ghq
brew install watch

brew install --cask iterm2
brew install --cask vlc
brew install --cask coteditor
brew install --cask alfred
brew install --cask adobe-acrobat-reader
brew install --cask xquartz
brew install --cask karabiner-elements
brew install --cask slack
brew install --cask 1password
brew install --cask docker
brew install --cask gpg-suite

# remove dust
brew cleanup
