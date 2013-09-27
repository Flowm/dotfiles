#############################################################################
#
# If not running interactively, don't do anything
if [ -n "$PS1" ]; then
#[ -z "$PS1" ] && return

#############################################################################
# Host detection
#
OS=`uname`
case "$OS" in
	OpenBSD) 
		HOST=`hostname -s`
	;;
	Linux)
		HOST=`uname -n`
	;;
	*)
		HOST=`echo $HOSTNAME | sed "s/\([a-z]*\)\..*/\1/"`
	;;
esac

#############################################################################
# Username detection
#
USER=`whoami`
if [ $USER == "fmaurach" ]; then
	GeNUA="true"
fi

#############################################################################
# General
#
# Activate bash_completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	. /etc/bash_completion
fi

# Add $HOME/bin to path
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# Add $HOME/bin/binary to path (binary files only)
if [ -d "$HOME/bin/binary" ] ; then
	PATH="$HOME/bin/binary:$PATH"
fi

# Add $HOME/bin/work to path
if [ -d "$HOME/bin/work" ] ; then
	PATH="$HOME/bin/work:$PATH"
fi

#############################################################################
# History
#
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=500000
#unset HISTSIZE
#unset HISTFILESIZE

export HISTTIMEFORMAT="%s "
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo $HOST $$ $USER \
				"$(history 1)" >> ~/.bash_eternal_history'

#############################################################################
# Behaviour
#
# VI mode
set -o vi

# ^p check for partial match in history
bind -m vi-insert "\C-p":dynamic-complete-history

# ^n cycle through the list of partial matches
bind -m vi-insert "\C-n":menu-complete

# ^l clear screen
bind -m vi-insert "\C-l":clear-screen
bind -m vi-command "\C-l":clear-screen

#############################################################################
# Screen
#
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Promt
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	chroot=$(cat /etc/debian_chroot)
fi

# Git
export MANPATH=/usr/local/git/man:$MANPATH
function parse_git_branch {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

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
		PS1="${LRED}\u${NOCOLOR}@${LGREEN}\h${NOCOLOR}: ${LBLUE}\w${NOCOLOR} \$(parse_git_branch)\$ "
		#PS1="\[\033[1;31m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\]: \[\033[1;34m\]\w \[\033[00m\] \$(parse_git_branch)\$ "
	else
		PS1='\u@\h:\w\$ '
	fi
else
	PS1='\u@\h:\w\$ '
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

#############################################################################
# Aliases - General
#

export EDITOR=vim

# Some more ls aliases
alias ll='ls -alF'
alias la='ls -Al'
alias l='ls -CF'
alias tree='tree -Csu | less -R'

# Verzeichnisnavigation
#alias .='pwd' #RLY STUPID ALIAS
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias cdfh='cd ~/Dropbox/Documents/FH/'
alias cddc='cd ~/Dropbox/Code/'
alias du-h='du -h --max-depth=1 |sort -rh'
alias findh='find . -iname'

# Own
#alias mv='mv -b'
alias a='ack'
alias g='git'
alias gr='grep -iIR'
alias gr='gre'
alias h='history'
alias j='jiffyi'
alias v='vim'
alias ssh-CMn='ssh -o ControlMaster=no'
alias ssh-CMs='ls ~/.tmp/'
alias jsocks='java -DsocksProxyHost=localhost'
alias ctodo='clear && todo'

# Sync
alias rsyncc='rsync -e ssh --ipv4 -aiurP'
alias carsync='rsync -e ssh --ipv4 -aiurPL carsten:fm/ ~/Documents/carsync/'
alias carsync-50='rsync -e ssh --ipv4 -aiurPL carsten:fm/ ~/Documents/carsync/ --bwlimit=50'
alias carsync-100='rsync -e ssh --ipv4 -aiurPL carsten:fm/ ~/Documents/carsync/ --bwlimit=100'
alias carsync-500='rsync -e ssh --ipv4 -aiurPL carsten:fm/ ~/Documents/carsync/ --bwlimit=500'
alias carsync-win='rsync -rltiuP ~/Documents/carsync/ /run/user/flow/gvfs/smb-share:server=nowhere,share=inc/carsync'
alias carsync-usb='rsync -rltiuP ~/Documents/carsync/ /media/flow/FastStick/carsync'

# Some nice little scripts
alias ping88='ping 8.8.8.8'
alias pwgen='cat /dev/urandom | tr -dc A-Za-z1-9 | head -c 32 && echo'
alias hex2ip='perl -e "\$hip = sprintf(\"%08s\", \$ARGV[0]); print hex(substr(\$hip,0,2)).\".\"; print hex(substr(\$hip,2,2)).\".\"; print hex(substr(\$hip,4,2)).\".\"; print hex(substr(\$hip,6,2)).\"\n\";"'
alias ip2hex='perl -e "foreach (split /\\./, \$ARGV[0]) {printf \"%x\", \$_;}print \"\n\";"'
alias most='history | awk '\''{print $2}'\'' | awk '\''BEGIN{FS="|"}{print $1}'\'' | sort | uniq -c | sort -n | tail -n 20 | sort -nr'
alias nmapult='sudo nmap --spoof-mac Cisco --data-length 9 -f -v -n -O -sS -sV -oA ~/.tmp/scan/nmap --log-errors -append-output -p T:1-1024,1433,2222,2249,7778,8080,9999 --randomize-hosts'
alias http='python -m SimpleHTTPServer'
alias httptest='wget cachefly.cachefly.net/100mb.test -O /dev/null'
alias pwcr='read -s pass; echo $pass | md5sum | base64 | cut -c -16 ; unset pass'
alias openports='netstat -anp --tcp --udp | grep LISTEN'
alias tcpdumpsu='sudo tcpdump not arp and not stp and not ip proto 112 and not proto 89'
manswitch() { man $1 | less -p "^ +-$2"; }
alias mansw='manswitch'
manpdf() { man -t $1 | ps2pdf - $1.pdf; }
say() { mplayer "http://translate.google.com/translate_tts?q=$1"; }
say2() { if [[ "${1}" =~ -[a-z]{2} ]]; then local lang=${1#-}; local text="${*#$1}"; else local lang=${LANG%_*}; local text="$*";fi; mplayer "http://translate.google.com/translate_tts?ie=UTF-8&tl=${lang}&q=${text}" &> /dev/null ; }
quietly() { $* 2> /dev/null > /dev/null; }
compile() { gcc -Wall $1.c -lm -o $1 && ./$1; }
alias junitc='javac -cp .:/usr/share/java/junit4.jar'
alias junit='java -cp .:/usr/share/java/junit4.jar org.junit.runner.JUnitCore'
compilec90() { gcc -Wall $1.c -std=c90 -lm -o $1 && ./$1; }
compilecpp() { g++ -Wall $1.c -std=c90 -lm -o $1 && ./$1; }
cmdfu() { curl -Ls "commandlinefu.com/commands/matching/$1/`echo -n $1|base64`/sort-by-votes/plaintext"| sed '1,2d;s/^#.*/&/g'; }

# SSH Agent attach to running agent
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
		fi
		test -e $AGENTFILE && source $AGENTFILE
	fi
	if [ "$1" == "-a" ]; then
		ssh-add ~/.ssh/fmaurachprod ~/.ssh/fmaurachtest
	fi
	if [ "$1" == "-k" ]; then
		ssh-agent -k
	fi
}

# Marks
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
export MARKPATH=$HOME/.marks
function jump { 
	cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark { 
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark { 
    rm -i "$MARKPATH/$1"
}
function marks {
	find "$MARKPATH" -type l | while read filename; do
		printf "%-12s -> %s\n" $(basename ${filename}) $(readlink ${filename})
	done
}
_completemarks() {
	local curw=${COMP_WORDS[COMP_CWORD]}
	local wordlist=$(find $MARKPATH -type l -printf "%f\n")
	COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
	return 0
}
alias j='jump'
complete -F _completemarks jump j unmark

#############################################################################
# Aliases - Conditional
#

#----------------------------------------------------------------------------
# Linux Only
if [ $OS == "Linux" ]; then
	# Gnome only
	alias open='gnome-open'
	
	# Directory sorting only in gnu ls
	alias ll='ls -alF --group-directories-first'

	# No more Notify-send in new Ubuntu
	# Add an "alert" alias for long running commands. Use like so: sleep 1; alert
	#alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

#----------------------------------------------------------------------------
# G Prod only
if [ $GeNUA ]; then
	#General
	alias ifconfig='/sbin/ifconfig'
	alias zcheck='zcheck -lx'
	alias sieveedit='SIEVEFILE=`mktemp` && sieveshell --password=$PASSWORD -exec="get fmaurach.siv $SIEVEFILE" kolab >/dev/null && vim $SIEVEFILE && sieveshell --password=$PASSWORD -exec="put $SIEVEFILE fmaurach.siv" kolab >/dev/null && rm -f $SIEVEFILE'
	#Connections
	alias sshpf='ssh -t hpf-admin ssh'
	alias g730="luit -encoding ISO-8859-15 ssh g730"
	alias g731="luit -encoding ISO-8859-15 ssh g731"
	alias g740="luit -encoding ISO-8859-15 ssh g740"
	alias g741="luit -encoding ISO-8859-15 ssh g741"
	alias g810="luit -encoding ISO-8859-15 ssh g810"
	alias g811="luit -encoding ISO-8859-15 ssh g811"
	alias gkvm='ssh gkvm'
	#Firefoxes
	alias hpfox='ssh hpf-admin -N -D 1080 & firefox -P hpfsocks -no-remote'
	alias firedown='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc breakdown.genua firefox -no-remote'
	alias azchrome='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc azubi5 firefox -no-remote'
	#snow
	alias snowfox='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc snow firefox'
	alias snowvim='ssh -t snow vim'
	alias snowvimtmp='snowvim tmp.txt'
fi

#----------------------------------------------------------------------------
# G Dev only
if ([ $GeNUA ] && [ -f ~/.aegis ]); then
	. ~/.aegis
	alias c='AEP g2z '
	alias ashowd='aed && showd'
	alias ack='ack.pl --follow -a'
	alias gcd='cd /data/git/fmaurach/gz/'
fi

#----------------------------------------------------------------------------
# Non GeNUA and probably Admin
if [ !$GeNUA ]; then
	# Add $HOME/bin/sudo to path
	if [ -d "$HOME/bin/sudo" ] ; then
		PATH="$HOME/bin/sudo:$PATH"
	fi
	# apt-get Shortcuts
	alias apt-up='sudo apt-get update'
	alias apt-diup='sudo apt-get update && sudo apt-get dist-upgrade'
	alias apt-tdiup='sudo tsocks apt-get update && sudo tsocks apt-get dist-upgrade'

	# Directory Navigation
	alias cdfh='cd ~/Dropbox/Documents/FH/'
	alias cddc='cd ~/Dropbox/Code/'

	# FH Rosenheim VPN
	alias fh-vpn-ext='sudo vpnc-connect /etc/vpnc/hs-extern.conf'
	alias fh-vpn-int='sudo vpnc-connect /etc/vpnc/hs-intern.conf'
	alias fh-vpn-stop='sudo vpnc-disconnect'
fi

#----------------------------------------------------------------------------
# Proxys
#if [ $ALL_PROXY ]; then
	#alias curl='curl --socks4 localhost'
#fi

#----------------------------------------------------------------------------
# Additional aliases if any
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

#############################################################################
# Non interactiv shells
fi

# This loads RVM into a shell session.
if [ -s "/usr/local/lib/rvm" ] ; then
	. "/usr/local/lib/rvm"
	if [ -d "$HOME/bin/rvm" ] ; then
		PATH="$HOME/bin/rvm:$PATH"
	fi
fi
if [ -s "$HOME/.rvm/scripts/rvm" ] ; then
	. "$HOME/.rvm/scripts/rvm"
	if [ -d "$HOME/bin/rvm" ] ; then
		PATH="$HOME/bin/rvm:$PATH"
		PATH="$HOME/.rvm/bin:$PATH"
	fi
	if [ -d "$HOME/bin/rvm" ] ; then
		PATH="$HOME/bin/rvm:$PATH"
	fi
fi
