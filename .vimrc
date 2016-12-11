"標準設定
source ~/dotfiles/.vimrc.basic

"dein
source ~/dotfiles/.vimrc.dein

"インフラ
source ~/dotfiles/.vimrc.infra

"プログラミング
source ~/dotfiles/.vimrc.programing

"if NeoVim
if has('nvim')
  source ~/dotfiles/.vimrc.nvim
endif
