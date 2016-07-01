#!/bin/bash -eu

#update Homebrew
brew update
brew upgrade

#shell
brew install zsh
brew install mobile-shell

#Utilities
#install coreutills
brew install openssl
brew install libyaml
brew install readline

#git
brew install git
brew install git-flow
brew install tig

#font
brew tap sanemat/font
#install ricty --powerline

#tools
brew install tmux
brew install nkf
brew install vim --with-lua
brew install w3m
brew install curl
brew install wget
brew install tree
brew install nmap
## TeX
brew install ghostscript
brew install imagemagick
## movie
brew install ffmpeg
brew install mplayer --use-gcc
brew install aalib
#brew install libcasa --use-gcc
## peco
brew install go
brew tap peco/peco
brew install peco

## Homebrew-cask
brew tap phinze/homebrew-cask || true
brew install brew-cask

brew cask install iterm2
#brew cask install android-studio
#brew cask install handbrake
#brew cask install audacity
brew cask install vlc
brew cask install thunderbird
brew cask install evernote
brew cask install dropbox
brew cask install coteditor
brew cask install growlnotify
#brew cask install limechat
#brew cask install sublime-text
brew cask install skype
#brew cask install yorufukurou
brew cask install alfred
brew cask install pandoc
brew cask install adobe-reader
#cask install wiresheke
brew cask install xquartz
brew cask install basictex
brew cask install mac-linux-usb-loader
brew cask install virtualbox
brew cask install vagrant
brew cask install hipchat

# install java
brew tap caskroom/versions

brew cask install java7
brew cask install java6

brew cask alfred link

#remove dust
brew cleanup
