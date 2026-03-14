########################################################################
# General
########################################################################

[ -e "${HOME}/.shcfg/env" ] && source "${HOME}/.shcfg/env"

########################################################################
# OMZ and prompt config
########################################################################

if ! [ -e "${HOME}/.shcfg/myc-omz-disable" ]; then
    # OMZ Active
    export ZSH=$HOME/.oh-my-zsh
    export ZSH_CUSTOM=$HOME/.shcfg/.omz-custom

    # Disable oh-my-zsh autoupdate
    DISABLE_AUTO_UPDATE="true"

    # Use case-sensitive completion.
    CASE_SENSITIVE="true"

    # Display red dots when waiting for compltion
    COMPLETION_WAITING_DOTS="true"

    # Disable string escaping during paste
    DISABLE_MAGIC_FUNCTIONS=true

    # Don't overwrite the title
    DISABLE_AUTO_TITLE="true"

    # Disable directory permission check
    ZSH_DISABLE_COMPFIX="true"

    # Show command execution time after given number of seconds.
    REPORTTIME=30

    # Long history
    export HISTSIZE=400000
    export SAVEHIST=$HISTSIZE

    # Plugins
    plugins=(
        colored-man-pages
        docker
        extract
        history-substring-search
        z
        zsh-256color
        zsh-syntax-highlighting
    )
    if [[ -n "$MC_OSX" ]]; then
        plugins[$(($#plugins+1))]=macos
    fi

    # Theme
    #ZSH_THEME="avit"
    ZSH_THEME="mjreese"
    #ZSH_THEME="powerlevel10k/powerlevel10k"

    source $ZSH/oh-my-zsh.sh
else
    # OMZ disabled, only load powerlevel10k
    [ -d "${HOME}/.shcfg/.omz-custom/themes/powerlevel10k" ] && source "${HOME}/.shcfg/.omz-custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
fi

########################################################################
# Powerlevel config
########################################################################

[ -e "${HOME}/.p10k.zsh" ] && source "${HOME}/.p10k.zsh"

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
# Ignore back to back duplicates in history search
setopt hist_find_no_dups
# Trim superfluous spaces
setopt hist_reduce_blanks

########################################################################
# Aliases
########################################################################

[ -e "${HOME}/.shcfg/aliases" ] && source "${HOME}/.shcfg/aliases"

########################################################################
# Keybindings
########################################################################

# VI-Mode (add more https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/vi-mode/vi-mode.plugin.zsh)
bindkey -v

# Only use the local history for the arrow keys
up-line-or-local-history() {
	zle set-local-history 1
	zle history-substring-search-up
	zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
	zle set-local-history 1
	zle history-substring-search-down
	zle set-local-history 0
}
zle -N down-line-or-local-history

# Search local history on Arrow Up/Down
bindkey "${terminfo[kcuu1]}" up-line-or-local-history
bindkey "${terminfo[kcud1]}" down-line-or-local-history
bindkey '^[[A' up-line-or-local-history
bindkey '^[[B' down-line-or-local-history

# Search global history on PgUp/PgDown and vicmd k/j
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[5~' history-substring-search-up
bindkey '^[[6~' history-substring-search-down

# Allow pattern search with Ctrl-r
bindkey "^r" history-incremental-pattern-search-backward

# Last argument of previous command with ESC.
bindkey -M viins '\e.' insert-last-word
