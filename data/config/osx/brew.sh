#!/usr/bin/env bash

echo "Installing brew apps"
brewapps=(
    arp-scan
    bash
    boost
    carthage
    cmake
    git
    htop-osx
    jq
    mobile-shell
    mtr
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
brew install ${brewapps[@]}

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
    gource
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
)
brew install ${brewfonts[@]}
