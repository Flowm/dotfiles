########################################################################
# General
########################################################################

[ -e "${HOME}/.zsh/.env" ] && source "${HOME}/.zsh/.env"

########################################################################
# Antigen config
########################################################################

ADOTDIR=$HOME/.zsh/antigen-bundles
source "$HOME/.zsh/antigen/antigen.zsh"

antigen use oh-my-zsh

antigen bundle colored-man
antigen bundle extract
antigen bundle history
antigen bundle mosh
antigen bundle rsync

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
# Plugin config
########################################################################

# Display red dots when waiting for compltion
COMPLETION_WAITING_DOTS="true"

# Don't overwrite the title
DISABLE_AUTO_TITLE="true"

# Show command execution time after given number of seconds.
REPORTTIME=30

########################################################################
# Own
########################################################################

[ -e "${HOME}/.zsh/.aliases" ] && source "${HOME}/.zsh/.aliases"
