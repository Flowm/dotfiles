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
		color_prompt=yes
		;;
	Linux)
		HOST=`uname -n`
		color_prompt=yes
		PLATFORM=`uname -m`
		case "$PLATFORM" in
			armv6l)
				slowsys=yes
				;;
		esac
		;;
	CYGWIN*)
		HOST=`uname -n`
		no_prompt=yes
		;;
	*)
		HOST=`echo $HOSTNAME | sed "s/\([a-z]*\)\..*/\1/"`
		color_prompt=yes
		;;
esac

#############################################################################
# Username detection
#
USER=`whoami`
if [ $USER == "fmaurach" ]; then
	genua=yes
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


if [ -z $slowsys ]; then
	export HISTTIMEFORMAT="%s "
	PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo $HOST $$ $USER \
				"$(history 1)" >> ~/.bash_eternal_history'
fi

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

# Git
export MANPATH=/usr/local/git/man:$MANPATH
function parse_git_branch {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

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
		if [ -z $slowsys ]; then
			PS1="${LRED}\u${NOCOLOR}@${LGREEN}\h${NOCOLOR}: ${LBLUE}\w${NOCOLOR} \$(parse_git_branch)\$ "
			#PS1="\[\033[1;31m\]\u\[\033[0m\]@\[\033[1;32m\]\h\[\033[0m\]: \[\033[1;34m\]\w \[\033[00m\] \$(parse_git_branch)\$ "
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
alias vless='/usr/share/vim/vim74/macros/less.sh'
alias ssh-CMn='ssh -o ControlMaster=no'
alias ssh-CMs='ls ~/.tmp/'
alias jsocks='java -DsocksProxyHost=localhost'
alias ctodo='clear && todo'

# Sync
alias rsyncc='rsync -e ssh --ipv4 -aiurP'
alias carsync='rsync -e ssh --ipv4 -aiurPL carsten:fm/'
alias carsync-doc='rsync -e ssh --ipv4 -aiurPL carsten:fm/ ~/Documents/carsync/ --bwlimit=500'
alias carsync-towin='rsync -rltiuP ~/Documents/carsync/ /run/user/flow/gvfs/smb-share:server=nowhere,share=inc/carsync'
alias carsync-tousb='rsync -rltiuP ~/Documents/carsync/ /media/flow/FastStick/carsync'

# Some nice little scripts
alias ping88='ping 8.8.8.8'
alias most='history | awk '\''{print $2}'\'' | awk '\''BEGIN{FS="|"}{print $1}'\'' | sort | uniq -c | sort -n | tail -n 20 | sort -nr'
alias pwgen-own='cat /dev/urandom | tr -dc A-Za-z1-9 | head -c 32 && echo'
alias nmapult='sudo nmap --spoof-mac Cisco --data-length 9 -f -v -n -O -sS -sV -oA ~/.tmp/scan/nmap --log-errors -append-output -p T:1-1024,1433,2222,2249,7778,8080,9999 --randomize-hosts'
alias httpserver='python -m SimpleHTTPServer'
alias httptest='wget cachefly.cachefly.net/100mb.test -O /dev/null'
alias checksocks1080='curl --socks5-hostname localhost:1080 frcy.org/static/iq/1080'
alias checksocks1081='curl --socks5-hostname localhost:1081 frcy.org/static/iq/1081'
alias checksocks='checksocks1080 ; checksocks1081'
alias pwcr='read -s pass; echo $pass | md5sum | base64 | cut -c -16 ; unset pass'
alias openports='netstat -anp --tcp --udp | grep LISTEN'
alias openportscan='for p in {1..1024}; do nc -vzw0 open.zorinaq.com $p 2>/dev/null ; if [ $? -eq 0 ]; then echo $p; fi; done'
alias iptable-watch="sudo watch -n1 'echo \"Filter:\"; iptables -vL; echo; echo \"NAT:\"; iptables -vL -t nat'"
alias tcpdumpsu='sudo tcpdump not arp and not stp and not ip proto 112 and not proto 89'
alias fixwwwperm='sudo chown -R www-data:www-data /var/www/'
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
# Host snow Only
if [ $HOST == "snow" ]; then
	alias snowaussh='aussh reverse-snow.m && aussh p'
fi

#----------------------------------------------------------------------------
# Linux Only
if [ $OS == "Linux" ]; then
	# Gnome only
	alias open='gnome-open'
	
	# Directory sorting only in gnu ls
	alias ll='ls -alF --group-directories-first'
fi

#----------------------------------------------------------------------------
# G only
if [ $genua ]; then
	# G Prod only
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
	alias firedown='ssh -n -f -C -o CompressionLevel=9 -Y -c aes128-cbc breakdown.genua firefox -no-remote'
	alias azchrome='ssh -n -f -C -o CompressionLevel=9 -Y -c aes128-cbc azubi5 firefox -no-remote'
	#snow
	alias snowfox='ssh -n -f -C -o CompressionLevel=9 -Y -c arcfour snow firefox -no-remote'
	alias snowvim='ssh -t snow vim'
	alias snowvimtmp='snowvim tmp.txt'
	alias ashowd='aed && showd'
	alias ack='ack.pl --follow -a'

	#----------------------------------------------------------------------------
	# G Dev only
	if ([ $genua ] && [ -f ~/.aegis ]); then
		. ~/.aegis
	fi

	#----------------------------------------------------------------------------
	# Non genua and probably Admin
else
	# apt-get Shortcuts
	alias apt-up='sudo apt-get update'
	alias apt-diup='sudo apt-get update && sudo apt-get dist-upgrade'
	alias apt-diuptsocks='sudo tsocks apt-get update && sudo tsocks apt-get dist-upgrade'

	# Directory Navigation
	alias cdfh='cd ~/Dropbox/Documents/FH/'
	alias cddc='cd ~/Dropbox/Code/'

	# FH Rosenheim VPN
	alias fh-vpn-ext='sudo vpnc-connect /etc/vpnc/hs-extern.conf'
	alias fh-vpn-int='sudo vpnc-connect /etc/vpnc/hs-intern.conf'
	alias fh-vpn-stop='sudo vpnc-disconnect'

	alias xpra-xterm='xpra attach ssh:ws1.genua:46 --encoding=png'
	alias xpra-xterm-start='ssh ws1.genua "xpra start :46 --start-child=xterm --exit-with-children"'
	alias xpra-tnt='xpra attach ssh:ws1.genua:47 --encoding=png'
	alias xpra-tnt-start='ssh ws1.genua "xpra start :47 --start-child=/share/bin/tnt --exit-with-children"'
	alias xpra-thunderbird='xpra attach ssh:ws1.genua:48 --encoding=png'
	alias xpra-thunderbird-start='ssh ws1.genua "xpra start :48 --start-child=thunderbird --exit-with-children"'
	alias xpra-xchat='xpra attach ssh:ws1.genua:49 --encoding=png'
	alias xpra-xchat-start='ssh ws1.genua "xpra start :49 --start-child=xchat --exit-with-children"'
fi

#############################################################################
# Non interactiv shells
fi
