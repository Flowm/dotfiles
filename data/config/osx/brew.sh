#!/usr/bin/env bash
set -eu

action=install
#action=upgrade

echo "Installing brew apps"
brewapps=(
    ansible
    arp-scan
    avr-gcc
    avrdude
    bash
    boost
    carthage
    cask-repair
    cmake
    coreutils
    cppcheck
    ctags
    direnv
    dos2unix
    git
    git-cal
    git-quick-stats
    git-standup
    gnu-sed
    go
    gource
    hr
    htop
    iftop
    jq
    macvim
    mosh
    mosquitto
    mspdebug
    mtr
    nmap
    node
    pandoc
    picocom
    pv
    radare2
    rename
    sl
    sshuttle
    stlink
    telnet
    the_silver_searcher
    tmux
    unp
    watch
    wget
    xz
    youtube-dl
    zsh
)
brew $action "${brewapps[@]}"

echo "Installing brew cask apps"
brewcaskapps=(
    1password
    aerial
    alfred
    appcleaner
    arduino
    arq
    bettertouchtool
    coconutbattery
    coolterm
    dash
    dropbox
    eagle
    firefox
    flux
    google-backup-and-sync
    google-chrome
    handbrake
    istat-menus
    iterm2
    jqbx
    mactex
    obs
    papers
    postman
    raindropio
    saleae-logic
    skim
    skype
    slack
    spotify
    steam
    texpad
    tigervnc-viewer
    visual-paradigm-ce
    visual-studio-code
    vlc
)
brew cask install "${brewcaskapps[@]}"

echo "Installing brew fonts"
brew tap caskroom/fonts
brewfonts=(
    font-yanone-kaffeesatz
    font-inconsolata
    font-droid-serif
    font-source-code-pro
)
brew cask install "${brewfonts[@]}"
