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
SAVEHIST=1000
setopt bang_hist
setopt extended_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

#compl
autoload -U compinit;compinit

#color
autoload -U colors;colors
# 一般ユーザ時
 tmp_prompt="%{${fg[cyan]}%}%n%# %{${reset_color}%}"
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
         [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
			           PROMPT="%{${fg[white]}%}${HOST%%.*} ${PROMPT}"
           ;

           ### Title (user@hostname) ###
           case "${TERM}" in
           kterm*|xterm*|)
             precmd() {
                 echo -ne "\033]0;${USER}@${HOST%%.*}\007"
                   }
                     ;;
                    esac
#alias
#ssh
alias sshlasta="ssh why_waita@lasta.dip.jp"
alias sshnest="ssh -p 2222 why@moon.mma.club.uec.ac.jp"
alias sshsun="ssh n1310100@sun.edu.cc.uec.ac.jp"
alias sshmoon="ssh why@moon.mma.club.uec.ac.jp" 
alias portforward_sun='ssh n1310100@sun.edu.cc.uec.ac.jp -L8080:proxy-east.uec.ac.jp:8080'
alias portforward_nest='ssh why@moon.mma.club.uec.ac.jp -L8080:proxy-east.uec.ac.jp:8080 -p 2222'
alias sshhome='ssh whywaita@whywaita.com'
#ls
alias ls="ls -F -G"
alias ll="ls -l"
alias la="ls -a"
#other
alias mkrepo="platex Report.tex&&dvipdfmx Report.dvi"
alias more=less
alias rm="rm -i"
alias mkrepo="platex Report.tex&&dvipdfmx Report.dvi"

#rubyinstall
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

### Added by the Heroku Toolbelt
### お疲れ様です
export PATH="/usr/local/heroku/bin:$PATH"

#LaTeXinstall
export PATH="/usr/texbin:$PATH"
