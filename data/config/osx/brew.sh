#!/usr/bin/env bash
set -eu

action=install
#action=upgrade

echo "Installing brew apps"
brew_apps=(
    ansible
    arp-scan
    avrdude
    bash
    boost
    carthage
    cmake
    coreutils
    cppcheck
    cscope
    ctags
    direnv
    dos2unix
    git
    git-cal
    git-lfs
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
    mercurial
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
    zstd
)
brew $action "${brew_apps[@]}"

echo "Installing brew cask apps"
brew_cask=(
    1password
    aerial
    airflow
    alfred
    appcleaner
    arduino
    arq
    bettertouchtool
    coconutbattery
    coolterm
    dash
    discord
    drawio
    dropbox
    eagle
    firefox
    flux
    gcc-arm-embedded
    google-backup-and-sync
    google-chrome
    handbrake
    intel-power-gadget
    istat-menus
    iterm2
    jqbx
    ledger-live
    mactex
    obs
    papers
    parallels
    postman
    raindropio
    sequel-pro
    skim
    skype
    spotify
    steam
    suspicious-package
    texpad
    tigervnc-viewer
    visual-paradigm-ce
    visual-studio-code
    vlc
    wireshark
    zotero
)
brew cask install "${brew_cask[@]}"

echo "Installing brew cask driver apps"
brew tap homebrew/cask-drivers
brew_cask_drivers=(
    saleae-logic
)
brew cask install "${brew_cask_drivers[@]}"

echo "Installing brew cask repair"
brew install vitorgalvao/tiny-scripts/cask-repair

echo "Installing brew fonts"
brew tap caskroom/fonts
brew_fonts=(
    font-yanone-kaffeesatz
    font-inconsolata
    font-source-code-pro
)
brew cask install "${brew_fonts[@]}"
