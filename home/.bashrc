########################################################################
# General
########################################################################

# If not running interactively, don't do anything
if [ -n "$PS1" ]; then

# Start zsh?
MY_SHELL=
if [ -x /bin/zsh ] && [ ! -e $HOME/.bsh ] ; then
  MY_SHELL=/bin/zsh
fi
if [ -n "$MY_SHELL" ]; then
  case $- in
    *i*) SHELL=$MY_SHELL; export SHELL; exec "$MY_SHELL";;
  esac
fi

# Shared config
[ -e "${HOME}/.shcfg/.env" ] && source "${HOME}/.shcfg/.env"
[ -e "${HOME}/.shcfg/.aliases" ] && source "${HOME}/.shcfg/.aliases"

########################################################################
# Completion
########################################################################

# Activate bash_completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	. /etc/bash_completion
fi

# Use current version of git bash completion
if [ -f ~/.myconf/contrib/git-completion.bash ] && ! shopt -oq posix; then
	. ~/.myconf/contrib/git-completion.bash
	if [ -f ~/.myconf/contrib/git-prompt.sh ]; then
		. ~/.myconf/contrib/git-prompt.sh
	fi
fi
__git_complete g _git

########################################################################
# History
########################################################################

HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

########################################################################
# Behaviour
########################################################################

# VI mode
set -o vi

# ^p check for partial match in history
bind -m vi-insert "\C-p":dynamic-complete-history

# ^n cycle through the list of partial matches
bind -m vi-insert "\C-n":menu-complete

# ^l clear screen
bind -m vi-insert "\C-l":clear-screen
bind -m vi-command "\C-l":clear-screen

########################################################################
# Screen
########################################################################

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

color_prompt=yes
if [ -n "$color_prompt" ]; then
	if [ -x /usr/bin/tput ]; then #&& tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		#Set some colors
		BLACK="\[\033[0;30m\]"
		RED="\[\033[0;31m\]"
		GREEN="\[\033[0;32m\]"
		BROWN="\[\033[0;33m\]"
		BLUE="\[\033[0;34m\]"
		MAGENTA="\[\033[0;35m\]"
		CYAN="\[\033[0;36m\]"
		WHITE="\[\033[0;37m\]"
		#LIGHT
		LBLACK="\[\033[1;30m\]"
		LRED="\[\033[1;31m\]"
		LGREEN="\[\033[1;32m\]"
		LYELLOW="\[\033[1;33m\]"
		LBLUE="\[\033[1;34m\]"
		LMAGENTA="\[\033[1;35m\]"
		LCYAN="\[\033[1;36m\]"
		LWHITE="\[\033[1;37m\]"
		NOCOLOR="\[\033[0m\]"
		#Set the promt
		if [ -z $MC_SLOWSYS ]; then
			PS1="${LRED}\u${NOCOLOR}@${LGREEN}\h${NOCOLOR}: ${LBLUE}\w${NOCOLOR}\$(__git_ps1) \$ "
			#PS1="\[\033[1;31m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\]: \[\033[1;34m\]\w \[\033[00m\] \$(__git_ps1)\$ "
		else
			PS1="${LRED}\u${NOCOLOR}@${LGREEN}\h${NOCOLOR}: ${LBLUE}\w${NOCOLOR} \$ "
		fi
	else
		PS1='\u@\h:\w\$ '
	fi
else
	if [ -z "$no_prompt" ]; then
		PS1='\u@\h:\w\$ '
	fi
fi

# Enable color support of ls and also add handy aliases
if ([ -n "$color_prompt" ] && [ -x /usr/bin/dircolors ]); then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# Improved window titles
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;\u@\h: \w\a\]$PS1"
		export TERM=xterm-256color
		;;
	*)
		;;
esac

#PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

########################################################################
# Auth Agents
########################################################################

# GPG Agent
if [ -f "$HOME/.gnupg/gpg-agent-info-$MC_HOST" ]; then
	. "$HOME/.gnupg/gpg-agent-info-$MC_HOST"
	export GPG_AGENT_INFO
fi

# SSH Agent

# Fix Agent for tmux
if [ -e "$HOME/.ssh/agent_sock" ]; then
	agent="$HOME/.ssh/agent_sock"
fi
if [ -S "$SSH_AUTH_SOCK" ]; then
	# save file i f wrong
	if [ $? -ne 0 ] || [ ! -S "$agent" ]; then
		ln -fs "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
	fi
else
	if [ $? -eq 0 ]; then
		export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
	fi
fi

# Attach to running Agent
sagentadd() {
	mykeys=( "$HOME/.ssh/id_rsa" "$HOME/.ssh/oldkeys/id_rsa" "$HOME/.ssh/id_ecdsa" "$HOME/.ssh/fmaurachprod" "$HOME/.ssh/fmaurachtest" )
	for key in "${mykeys[@]}"; do
		if [ -e "$key" ]; then
			ssh-add $key
		fi
	done
}
sagent() {
	AGENTFILE=$HOME/.ssh/.agent.sh
	if [ -z "$1" ] || [ "$1" == "-s" ]; then
		if [ -e "$AGENTFILE" ]; then
			source $AGENTFILE
			ps -p $SSH_AGENT_PID > /dev/null
			if [ $? -ne 0 ]; then
				rm $AGENTFILE
			fi
		fi
		if [ ! -e "$AGENTFILE" ]; then
			ssh-agent | grep -v echo >&$AGENTFILE
			test -e $AGENTFILE && source $AGENTFILE
			sagentadd
		fi
	fi
	if [ "$1" == "-a" ]; then
		sagentadd
	fi
	if [ "$1" == "-k" ]; then
		ssh-agent -k
	fi
}

########################################################################
# Aliases - Bash only
########################################################################

# Some more ls aliases
alias ll='ls -Al'
alias la='ls -alF'
alias l='ls -1F'
alias tree='tree -Csu | less -R'

# Directory navigation
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

########################################################################
# TODO: Old stuff, move to script with options
########################################################################

# Sync
alias rsyncc='rsync -e ssh --ipv4 -aiurP'
alias carsync='rsync -e ssh --ipv4 -aiurPL carsten:fm/'
alias carsync-doc='rsync -e ssh --ipv4 -aiurPL carsten:fm/ ~/Documents/carsync/ --bwlimit=500'
alias carsync-towin='rsync -rltiuP ~/Documents/carsync/ /run/user/flow/gvfs/smb-share:server=nowhere,share=inc/carsync'
alias carsync-tousb='rsync -rltiuP ~/Documents/carsync/ /media/flow/FastStick/carsync'

########################################################################
# Non interactive shells
########################################################################
fi

if [ -d "$HOME/.rvm" ] ; then
	PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
	source ~/.rvm/scripts/rvm
fi
if [ -d "$HOME/.rbenv" ] ; then
	export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
	export PATH="$HOME/.rbenv/bin:$PATH"
	eval "$(rbenv init -)"
fi
