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

# git
export MANPATH=/usr/local/git/man:$MANPATH
function parse_git_branch {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
 }

color_prompt=yes

if [ -n "$color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
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
alias ll='ls -alF --group-directories-first' #TODO: Only Linux
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

alias cdfh='cd ~/Dropbox/Documents/FH/'
alias cddc='cd ~/Dropbox/Code/'
alias du-h='du -h --max-depth=1 |sort -rh'

# Mixed
#alias mv='mv -b'
alias h='history'
alias g='git'
alias j='jiffyi'
alias mygrep='grep -iIR'
alias myscp='rsync -e ssh --ipv4 -aiurP'
alias ssh-nCM='ssh -o ControlMaster=no'
alias ssh-sCM='ls ~/.tmp/'
alias jsocks='java -DsocksProxyHost=localhost'

#Some nice little scripts
alias pwgen='cat /dev/urandom | tr -dc A-Za-z1-9 | head -c 32 && echo'
alias hex2ip='perl -e "\$hip = sprintf(\"%08s\", \$ARGV[0]); print hex(substr(\$hip,0,2)).\".\"; print hex(substr(\$hip,2,2)).\".\"; print hex(substr(\$hip,4,2)).\".\"; print hex(substr(\$hip,6,2)).\"\n\";"'
alias ip2hex='perl -e "foreach (split /\\./, \$ARGV[0]) {printf \"%x\", \$_;}print \"\n\";"'
alias most='history | awk '\''{print $2}'\'' | awk '\''BEGIN{FS="|"}{print $1}'\'' | sort | uniq -c | sort -n | tail -n 20 | sort -nr'
alias nmapult='sudo nmap --spoof-mac Cisco --data-length 9 -f -v -n -O -sS -sV -oA ~/.tmp/scan/nmap --log-errors -append-output -p T:1-1024,1433,2222,2249,7778,8080,9999 --randomize-hosts'
alias http='python -m SimpleHTTPServer'
alias httptest='wget cachefly.cachefly.net/100mb.test -O /dev/null'
alias pwcr='read -s pass; echo $pass | md5sum | base64 | cut -c -16 ; unset pass'
alias openports='netstat -anp --tcp --udp | grep LISTEN'
manswitch() { man $1 | less -p "^ +$2"; }
manpdf() { man -t $1 | ps2pdf - $1.pdf; }
say() { mplayer "http://translate.google.com/translate_tts?q=$1"; }
say2() { if [[ "${1}" =~ -[a-z]{2} ]]; then local lang=${1#-}; local text="${*#$1}"; else local lang=${LANG%_*}; local text="$*";fi; mplayer "http://translate.google.com/translate_tts?ie=UTF-8&tl=${lang}&q=${text}" &> /dev/null ; }
#gdu() { t=$(df|awk 'NR!=1{sum+=$2}END{print sum }');sudo du / --max-depth=1|sed '$d'|sort -rn -k1 | awk -v t=$t 'OFMT="%d" {M=64; for (a=0;a<$1;a++){if (a>c){c=a}}br=a/c;b=M*br;for(x=0;x<b;x++){printf "\033[1;31m" "|" "\033[0m"}print " "$2" "(a/t*100)"% total"}'}
quietly() { $* 2> /dev/null > /dev/null; }
compile() { gcc -Wall $1.c -lm -o $1 && ./$1; }
compilec90() { gcc -Wall $1.c -std=c90 -lm -o $1 && ./$1; }

#############################################################################
# Aliases - Conditional
#
#----------------------------------------------------------------------------
# Gnome only
alias open='gnome-open'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#----------------------------------------------------------------------------
# G Prod only
if [ $GeNUA ]; then
	alias ifconfig='/sbin/ifconfig'
	alias sieveedit='SIEVEFILE=`mktemp` && sieveshell --password=$PASSWORD -exec="get fmaurach.siv $SIEVEFILE" kolab >/dev/null && vim $SIEVEFILE && sieveshell --password=$PASSWORD -exec="put $SIEVEFILE fmaurach.siv" kolab >/dev/null && rm -f $SIEVEFILE'
	alias z200='ssh z200'
	alias z301='ssh z301'
	alias firedown='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc breakdown.genua firefox -no-remote'
	alias firef0x='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc azubi5 firefox -no-remote'
	alias azchrome='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc azubi5 azchrome'
	alias gzchrome='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc blackswan gzchrome'
	alias gzfirefox='ssh -n -f -C -o CompressionLevel=9 -Y -c blowfish-cbc blackswan gzfirefox'
fi

#----------------------------------------------------------------------------
# G Dev only
if ([ $GeNUA ] && [ -f ~/.aegis ]); then
	. ~/.aegis
	alias c='AEP g2z '
	alias gcd='cd /data/git/fmaurach/gz/'
fi

#----------------------------------------------------------------------------
# Admin only
if [ !$GeNUA ]; then
	# apt-get Shortcuts
	alias acs='apt-cache search'
	alias agu='sudo apt-get update'
	alias agupg='sudo apt-get upgrade'
	alias agdupg='sudo apt-get dist-upgrade'
	alias agi='sudo apt-get install'
	alias agr='sudo apt-get remove'
	# aptitude Shortcuts
	alias apt='sudo aptitude'
	alias apts='sudo aptitude search'
	alias aptupd='sudo aptitude update'
	alias aptupg='sudo aptitude upgrade'
	alias aptdupg='sudo aptitude dist-upgrade'
	alias apti='sudo aptitude install'
	alias aptr='sudo aptitude remove'
fi

#----------------------------------------------------------------------------
# Proxys
if [ $ALL_PROXY ]; then
	alias curl='curl --socks4 localhost'
fi

#----------------------------------------------------------------------------
# FH Rosenheim VPN

alias fh-vpn-ext='sudo vpnc /etc/vpnc/hs-extern.conf'
alias fh-vpn-int='sudo vpnc /etc/vpnc/hs-intern.conf'
alias fh-vpn-stop='sudo pkill vpnc'

#----------------------------------------------------------------------------
# Additional aliases if any
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

#############################################################################
# Non interactiv shells
fi

# This loads RVM into a shell session.
[[ -s "/usr/local/lib/rvm" ]] && . "/usr/local/lib/rvm"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
