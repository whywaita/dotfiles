#startup
export LANG=ja_JP.UTF-8
setopt no_beep
setopt nolistbeep
setopt auto_pushd
setopt auto_cd
setopt correct
setopt notify
setopt prompt_subst
setopt equals

#history
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=100000000
setopt bang_hist
setopt extended_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

#default editer set
export EDITOR=nvim
export GIT_EDITOR=nvim

# set shell
export SHELL=/opt/homebrew/bin/zsh
export TERM="screen-256color"

#compl
autoload -U compinit;compinit

#color
autoload -U colors;colors
# 一般ユーザ時
 # tmp_prompt="%{${fg[cyan]}%}%n%# %{${reset_color}%}"
 tmp_prompt="%{${fg[cyan]}%}whywaita%# %{${reset_color}%}"
 tmp_prompt2="%{${fg[cyan]}%}%_> %{${reset_color}%}"
 tmp_rprompt="%{${fg[green]}%}[%~]%{${reset_color}%}"
 tmp_sprompt="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"

 # rootユーザ時(太字にし、アンダーバーをつける)
 if [ ${UID} -eq 0 ]; then
   tmp_prompt="%B%U${tmp_prompt}%u%b"
   tmp_prompt2="%B%U${tmp_prompt2}%u%b"
   tmp_rprompt="%B%U${tmp_rprompt}%u%b"
   tmp_sprompt="%B%U${tmp_sprompt}%u%b"
 fi

   PROMPT=$tmp_prompt    # 通常のプロンプト
   PROMPT2=$tmp_prompt2  # セカンダリのプロンプト(コマンドが2行以上の時に表示される)
   RPROMPT=$tmp_rprompt  # 右側のプロンプト
   SPROMPT=$tmp_sprompt  # スペル訂正用プロンプト
  # SSHログイン時のプロンプト
   [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && PROMPT="%{${fg[white]}%}${HOST%%.*} ${PROMPT}";

   ### Title (user@hostname) ###
   case "${TERM}" in
     kterm*|xterm*)
     precmd() {
     echo -ne "\033]0;${USER}@${HOST%%.*}\007"
     }
     ;;
   esac

#alias
#ls
alias ls="ls -F -G"
alias ll="ls -l"
alias la="ls -a"
#other
alias more=less
alias rm="rm -i"
alias nnmap="sudo nmap -sS -sV -Pn -p 1-65535"
alias gen-rand="cat /dev/urandom | LC_CTYPE=C tr -dc '[:alnum:]' | head -c"
#tmux
alias tmux="tmux -2 -u"
alias ta="tmux a -t"
alias tns="tmux new-session -s"
alias td="tmux detach"
alias trm="tmux kill-session -t"
#Lang
alias be="bundle exec"

# nodejs
export PATH=$PATH:./node_modules/.bin
# Go
export PATH=$PATH:$HOME/go/bin
# homebrew
export PATH=/opt/homebrew/bin:$PATH
# Util
export PATH=$HOME/bin:$PATH

ex () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1    ;;
      *.tar.gz)    tar xvzf $1    ;;
      *.tar.xz)    tar xvJf $1    ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xvf $1     ;;
      *.tbz2)      tar xvjf $1    ;;
      *.tgz)       tar xvzf $1    ;;
      *.zip)       unzip $1 -d ${1%.zip}  ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *.lzma)      lzma -dv $1    ;;
      *.xz)        xz -dv $1      ;;
      *)           echo "don't know how to extract '$1'..." ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^|' peco-src

## local固有設定
[ -f ~/.config/zsh.local ] && source ~/.config/zsh.local
