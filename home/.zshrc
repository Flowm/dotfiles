########################################################################
# General
########################################################################

[ -e "${HOME}/.shcfg/.env" ] && source "${HOME}/.shcfg/.env"

########################################################################
# OMZ config
########################################################################

export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.shcfg/.omz-custom

ZSH_THEME="jreese"

########################################################################
# Plugin config
########################################################################

# Use case-sensitive completion.
CASE_SENSITIVE="true"

# Display red dots when waiting for compltion
COMPLETION_WAITING_DOTS="true"

# Don't overwrite the title
DISABLE_AUTO_TITLE="true"

# Show command execution time after given number of seconds.
REPORTTIME=30

# Long history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

########################################################################
# Plugins
########################################################################

plugins=(
	colored-man-pages
	command-not-found
	extract
	mosh
	rbenv
	rsync
	z
	zsh-256color
	zsh-syntax-highlighting
)
if [[ -n "$MC_OSX" ]]; then
	plugins[$(($#plugins+1))]=osx
fi

source $ZSH/oh-my-zsh.sh

########################################################################
# ZSH config
########################################################################

# No terminal bell
setopt nobeep
# change dir without cd
setopt autocd
# Make cd behave like pushd
setopt autopushd
# Ignore duplicate paths on pushd
setopt pushdignoredups

########################################################################
# Aliases
########################################################################

[ -e "${HOME}/.shcfg/.aliases" ] && source "${HOME}/.shcfg/.aliases"

########################################################################
# Keybindings
########################################################################
# Local history on arrow keys
if [[ "${terminfo[kpp]}" != "" ]]; then
	bindkey "${terminfo[kpp]}" up-line-or-local-history;
fi
if [[ "${terminfo[knp]}" != "" ]]; then
	bindkey "${terminfo[knp]}" down-line-or-local-history;
fi
bindkey "^[[1;5A" up-line-or-history    # [CTRL] + Cursor up
bindkey "^[[1;5B" down-line-or-history  # [CTRL] + Cursor down

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
