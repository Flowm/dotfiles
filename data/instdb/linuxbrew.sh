#!/usr/bin/env bash
set -eu

# Install gawk if missing
if ! command -v foo >/dev/null 2>&1; then
    echo "Install gawk to bootstrap linuxbrew (Ctrl-D for local install)"
    mkdir -p ~/opt && cd ~/opt
    apt-get download gawk
    dpkg -x gawk_1%3a4.1.1+dfsg-1_amd64.deb .
    export LD_LIBRARY_PATH=$HOME/opt/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH:-}
    export PATH=$HOME/opt/usr/bin:$PATH
fi

# Install linuxbrew
if [ ! -d $HOME/.linuxbrew ]; then
    echo "Install Linuxbrew (Ctrl-D for local install)"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
fi
export PATH="$HOME/.linuxbrew/bin:$PATH"

# Initial update and git install if missing
brew update

# Install gawk
brew install gawk

# Export path
echo "Add linuxbrew path to config"
if ! grep linuxbrew ~/.zshrc >/dev/null 2>&1; then
    echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.zshrc
    echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >>~/.zshrc
    echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >>~/.zshrc
fi
if ! grep linuxbrew ~/.bashrc >/dev/null 2>&1; then
    echo 'export PATH="$HOME/.linuxbrew/bin:$PATH"' >>~/.bashrc
    echo 'export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"' >>~/.bashrc
    echo 'export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"' >>~/.bashrc
fi

echo "Install brew apps"
brewapps=(
    bash
    git
    htop
    nginx
    rename
    tmux
    zsh
    wget
)
for app in ${brewapps[@]}; do
    echo "brew install $app"
    brew install $app
done
