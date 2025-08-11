#!/usr/bin/env bash
set -eu

action=install
#action=upgrade

echo "Installing brew apps"
brew_apps=(
    # ansible
    # apngasm
    arp-scan
    bpytop
    brotli
    colima
    coreutils
    direnv
    docker
    docker-completion
    docker-compose
    dos2unix
    git
    # git-cal
    # git-filter-repo
    git-lfs
    # git-quick-stats
    # git-sizer
    gnu-sed
    # go
    gource
    htop
    # iftop
    imagemagick
    jq
    languagetool
    # mitmproxy
    mosh
    # mosquitto
    mtr
    ncdu
    neovim
    nmap
    node
    pandoc
    # picocom
    # pngcrush
    # pngquant
    # poetry
    pv
    pwgen
    # radare2
    rename
    rsync
    sshpass
    sshuttle
    telnet
    tmux
    tmuxinator
    tmuxinator-completion
    tree
    unp
    watch
    wget
    xz
    yt-dlp
    zsh
    zstd
)
brew $action "${brew_apps[@]}"

echo "Installing brew cask apps"
brew_cask=(
    1password
    # airserver
    alfred
    # appcleaner
    arq
    balenaetcher
    # betaflight-configurator
    bettertouchtool
    blender
    # chromium
    coconutbattery
    cyberduck
    # db-browser-for-sqlite
    discord
    # drawio
    firefox
    # flux
    geekbench
    google-chrome
    # google-cloud-sdk
    google-drive
    google-earth-pro
    grandperspective
    gyroflow
    handbrake
    # imhex
    # inkscape
    istat-menus
    iterm2
    ledger-live
    losslesscut
    # microsoft-teams
    # moonlight
    # ngrok
    notion
    # nvidia-geforce-now
    obs
    # openaudible
    panoply
    # parallels
    # postman
    qgis
    raindropio
    # sidequest
    skim
    spotify
    steam
    # suspicious-package
    # teamviewer
    temurin
    # texpad
    # tigervnc-viewer
    # utm
    visual-studio-code
    vlc
    # webstorm
    # whisky
    # wireshark
    # zoom
    # zotero
)
brew install --cask "${brew_cask[@]}"

#echo "Installing brew cask driver apps"
#brew tap homebrew/cask-drivers
#brew_cask_drivers=(
#    saleae-logic
#)
#brew install "${brew_cask_drivers[@]}"

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
