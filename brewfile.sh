#!/bin/bash -eu

#update Homebrew
brew update
brew upgrade

#shell
brew install zsh
#brew install mobile-shell

#Utilities
#install coreutills
brew install openssl
brew install libyaml
brew install readline

#git
brew install git
#brew install tig

#font
brew tap sanemat/font
#install ricty --powerline

#tools
brew install tmux
brew install nkf
brew install vim 
brew install w3m
brew install curl
brew install wget
brew install tree
brew install nmap

# dev
brew install go
brew install nvim
brew install kubectl
brew install gpg2

## Homebrew-cask
brew tap caskroom/cask

brew cask install iterm2
brew cask install vlc
brew cask install coteditor
brew cask install alfred
brew cask install pandoc
brew cask install adobe-reader
brew cask install xquartz
brew cask install karabiner-elements
brew cask install slack
brew cask install 1password

#remove dust
brew cleanup
