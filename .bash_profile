# .bash_profile if .bashrc is not automatically loaded in login shells
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
