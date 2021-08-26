#!/usr/bin/env bash
set -eu

action=install
#action=upgrade

echo "Installing brew apps"
brew_apps=(
    ansible
    arp-scan
    bpytop
    coreutils
    direnv
    dos2unix
    git
    git-cal
    git-lfs
    git-quick-stats
    gnu-sed
    go
    gource
    htop
    iftop
    jq
    mosh
    mosquitto
    mtr
    ncdu
    nmap
    node
    pandoc
    picocom
    pv
    pwgen
    radare2
    rename
    rsync
    sl
    sshuttle
    telnet
    tmux
    unp
    vim
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
    aerial
    airserver
    alfred
    appcleaner
    arq
    balenaetcher
    betaflight-configurator
    bettertouchtool
    coconutbattery
    cyberduck
    dash
    discord
    docker
    drawio
    dropbox
    firefox
    flux
    google-chrome
    google-drive-file-stream
    grandperspective
    handbrake
    istat-menus
    iterm2
    jqbx
    ledger-live
    obs
    panoply
    parallels
    postman
    qgis
    raindropio
    skim
    spotify
    steam
    suspicious-package
    texpad
    tigervnc-viewer
    visual-studio-code
    vlc
    wireshark
    zotero
)
brew install "${brew_cask[@]}"

echo "Installing brew cask driver apps"
brew tap homebrew/cask-drivers
brew_cask_drivers=(
    saleae-logic
)
brew install "${brew_cask_drivers[@]}"

#echo "Installing brew cask repair"
#brew install vitorgalvao/tiny-scripts/cask-repair
#
#echo "Installing brew-cask-upgrade"
#brew tap buo/cask-upgrade

echo "Installing brew fonts"
brew tap homebrew/cask-fonts
brew_fonts=(
    font-yanone-kaffeesatz
    font-inconsolata
    font-source-code-pro
)
brew install "${brew_fonts[@]}"
