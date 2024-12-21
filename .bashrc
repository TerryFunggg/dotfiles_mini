#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '
PS1='\e[1;34m\w\e[m \e[1;31m-> \e[m'

# History 
HISTCONTROL=ignoredups
HISTSIZE=2000
HISTFILESIZE=2000
shopt -s histappend

# Default editor
export EDITOR=vim

# Color
export TERM=xterm-256color
export LESS="-QRS"

# alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'


# files
source ~/.alias
