########################################################################
# General
########################################################################

# Shared config
[ -e "${HOME}/.shcfg/.env" ] && source "${HOME}/.shcfg/.env"
[ -e "${HOME}/.shcfg/.aliases" ] && source "${HOME}/.shcfg/.aliases"

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

########################################################################
# History
########################################################################

# Long history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

########################################################################
# Antigen config
########################################################################

ADOTDIR=$HOME/.zsh/antigen-bundles
source "$HOME/.zsh/antigen/antigen.zsh"

antigen use oh-my-zsh

antigen bundle colored-man-pages
antigen bundle extract
antigen bundle history
antigen bundle mosh
antigen bundle rsync
antigen bundle rbenv

antigen bundle command-not-found
antigen bundle zsh-users/zsh-completions src
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle rupa/z
antigen bundle chrissicool/zsh-256color

if [[ -n "$OSX" ]]; then
	antigen bundle brew
	antigen bundle osx
fi

antigen theme jreese

antigen apply

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
# Print exit value on fail
setopt printexitvalue

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
