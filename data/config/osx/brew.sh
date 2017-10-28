#!/usr/bin/env bash
set -eu

action=install
#action=upgrade

echo "Installing brew apps"
brewapps=(
    arp-scan
    avr-gcc
    avrdude
    bash
    boost
    carthage
    cmake
    coreutils
    git
    git-cal
    git-standup
    git-quick-stats
    gource
    htop
    jq
    mosh
    mtr
    pandoc
    picocom
    rename
    the_silver_searcher
    tmux
    unp
    watch
    wget
    youtube-dl
    zsh
)
brew $action ${brewapps[@]}

echo "Installing brew cask apps"
brewcaskapps=(
    1password
    aerial
    alfred
    appcleaner
    arduino
    arq
    bettertouchtool
    dash
    dropbox
    filezilla
    firefox
    flux
    google-chrome
    handbrake
    istat-menus
    iterm2
    mactex
    macvim
    obs
    papers
    reflector
    skim
    skype
    slack
    spotify
    steam
    synergy
    teamspeak-client
    texpad
    tigervnc-viewer
    vagrant
    virtualbox
    vlc
)
brew cask install ${brewcaskapps[@]}

echo "Installing brew fonts"
brew tap caskroom/fonts
brewfonts=(
    font-yanone-kaffeesatz
    font-inconsolata
    font-droid-serif
    font-source-code-pro
)
brew cask install ${brewfonts[@]}
