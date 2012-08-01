" README {
" vim: set foldmarker={,} foldlevel=0 spell:
"
"	That's my personal .vimrc. As quite a lot of efforts went into this,
"	I would be glad if this was useful for anybody else than me.
"
"	And here it is on Github, although there seem to be thousands of
"	other great .vimrcs there:
"		https://github.com/flowm/vimrc
" }

" Basic {
		"VIM not VI wanted
	set nocompatible
		"Pantogen is used to manage vim plugins
	call pathogen#infect()
	call pathogen#helptags()
	syntax on
	filetype plugin indent on
		"Explicitly define xterm as environment
	behave xterm
		"More screen updates
	set ttyfast
		"No modeline for security
	set nomodeline
	"set encoding=utf-8
	set backspace=indent,eol,start
" }

" General {
	" Backup and TMP Files {
		set backup
		set backupdir=~/.tmp/.vimbak
		set directory=~/.tmp/.vimtmp,.
		set history=1000
	" }
	" Tab completion {
		set wildmenu
		set wildmode=list:longest,list:full
		set wildignore+=*.o,*.obj,.git,*.rbc,*.class,.svn,vendor/gems/*
	" }
	" Searching {
			"Highlightsearch
		set hlsearch
			"Start searching with the first Character
		set incsearch
			"Ignore Case
		set ignorecase
			"Match Case if searchstring starts with uppercase
		set smartcase
			"Global search by default
		set gdefault
			"Treat more Characters as special(like in perl) when searching (e.g. . *)
		set magic
	" }
	" Spelling {
		set spelllang=en_us,de_de
	" }
" }

" Appearance and handling {
	" Theme {
		colorscheme evening
		set background=dark
	" }
	" Statusbar {
			"Show the Ruler (if statusbar isn't working)
		"set ruler
			"Renaming xterm window
		set title
			"Don't show line numbers
		set nonumber
			"Always show the status bar
		set laststatus=2
	" }
	" Statusline {
			"Clear the statusline
		set statusline=
			"Tail of the filename
		set statusline=%t\ 
			"Complete filename
		"set statusline=%f\ 
			"File format
		set statusline+=[%{&fileformat},
			"File encoding
		set statusline+=%{strlen(&fenc)?&fenc:&enc}]
			"Flag
		set statusline+=%m%r%h%w
			"Filetype
		set statusline+=[%Y]
			"Last modified
		set statusline+=%20(%{strftime(\"%d/%m/%y\ -\ %H:%M\")}%)
			"Left/Right separator
		set statusline+=%=
			"Current module name
		set statusline+=%{synIDattr(synID(line('.'),col('.'),1),'name')}\ 
			"HEX value of char
		"set statusline+=[HEX:0x%2B]\ 
			"ASCII value of char
		"set statusline+=[ASCII:%3b]\ 
			"COL + LIN
		set statusline+=%-20([COL:%2v][LIN:%3l/%L]%)\ 
			"Percentage of file
		set statusline+=[%3p%%]
	" }
	" Misc Handling {
			"Always let 5 lines below and above the cursor on the screen
		set scrolloff=5
			"Bracket matching
		set showmatch
			"Show unfinished commands
		set showcmd
			"No Bell
		set noerrorbells visualbell
	" }
" }

" Text Formatting/Layout {
	" Whitespace and Tab display {
		set list
		set list listchars=tab:>.,trail:.
		"set list listchars=tab:>.,trail:·
	" }
	" Overlong lines display {
			"Break the line instead of scrolling right
		set wrap
			"Don't break lines
		set wrapmargin=0
			"But continue with a mark in the next line
		set showbreak=>>>
	" }
	" Indention {
			"One Tab per indentation level. 4 column wide Tabs.
			"Intelligently detect current indention level
		set smartindent
			"Size of real Tabs
		set tabstop=4
			"Indent amount when using TAB
		set softtabstop=4
			"Indent amount when using cindent, >>, ..
		set shiftwidth=4
			"Do not expand tabs to spaces
		set noexpandtab
	" }
	" Folding (disabled) {
			"Currently disable folding
		set nofoldenable
			"Make folding indent sensitive
		set foldmethod=indent
	" }
" }

" Mappings and functions {
	" Misc {
			"Easier escape
		inoremap <F1> <ESC>
		nnoremap <F1> <ESC>
		vnoremap <F1> <ESC>
		inoremap jj <ESC>
			"Match brackets key
		nnoremap <tab> %
		vnoremap <tab> %
			"Clear highlight
		map <silent> <C-l> :silent nohl<CR>
			"Save as root
		cmap w!! %!sudo tee > /dev/null %
	" }
	" Custom Keyset {
		let mapleader = ","
			"Reselect just pasted content
		nnoremap <leader>v V`]
			"Split Window and switch over to it
		nnoremap <leader>w <C-w>v<C-w>l
	" }
	" Disable arrow keys {
		nnoremap <up> <nop>
		nnoremap <down> <nop>
		nnoremap <left> <nop>
		nnoremap <right> <nop>
		inoremap <up> <nop>
		inoremap <down> <nop>
		inoremap <left> <nop>
		inoremap <right> <nop>
		nnoremap j gj
		nnoremap k gk
	" }
	" Syntax checking {
		map <leader>spl :w !perl -c %<CR>
		map <leader>srb :w !ruby -c %<CR>
		map <leader>sgcc :w !gcc -fsyntax-only %<CR>
		map <leader>sjava :w !javac %<CR>
	" }
	" <F5>-<F8> {
		" <F5> Toggle spell checking {
			map <F5> :set spell!<CR><Bar>:echo 'Spell check: ' . strpart('OffOn', 3 * &spell, 3)<CR>
		" }
		" <F6> Toggle paste mode {
			set pastetoggle=<F6>
		" }
		" <F7> Toggle whitespace and tab display {
			function ToggleList()
				if &list
					set nolist
				else
					set list
				endif
			endfunction
			map <silent> <F7> :call ToggleList() <CR>
		" }
		" <F8> Toggle line numbers {
			function ToggleNumber()
				if &number
					set nonumber
				else
					set number
				endif
			endfunction
			map <silent> <F8> :call ToggleNumber() <CR>
		" }
	" }
	" HTML encode all vowels with Strg-H {
		function HtmlEscape()
			silent s/ö/\&ouml;/eg
			silent s/ä/\&auml;/eg
			silent s/ü/\&uuml;/eg
			silent s/Ö/\&Ouml;/eg
			silent s/Ä/\&Auml;/eg
			silent s/Ü/\&Uuml;/eg
			silent s/ß/\&szlig;/eg
		endfunction
		map <silent> <c-h> :call HtmlEscape()<CR>
	" }
" }
" Settings for addons {
	let g:Perl_GlobalTemplateFile='~/.vim/perl-support/templates/Templates'
" }

" Conditionals {
	if has('autocmd')
		au BufRead,BufNewFile *.rb,*.rhtml set tabstop=2
		au BufRead,BufNewFile *.rb,*.rhtml set softtabstop=2
		au BufRead,BufNewFile *.rb,*.rhtml set shiftwidth=2
		au BufRead,BufNewFile *.rb,*.rhtml set expandtab
		"Deleting multible spaces at once
		au BufRead,BufNewFile *.rb,*.rhtml set smarttab
		au BufRead,BufNewFile *.ino set tabstop=2
		au BufRead,BufNewFile *.ino set softtabstop=2
		au BufRead,BufNewFile *.ino set shiftwidth=2
		au BufRead,BufNewFile *.ino set expandtab
		au BufNewFile,BufRead *.pde set ft=arduino
		au BufNewFile,BufRead *.ino set ft=arduino
		au BufNewFile,BufRead *.README set textwidth=72
		au BufNewFile,BufRead *aegis-*	set textwidth=72
	endif
" }

" To be tested/integrated {
	"set mouse=a
	"set confirm
	"au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
	"au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
	"au FocusLost * :wa
		"Column to mark overlong text
	"set colorcolumn=85
	"hi ColorColumn ctermbg=lightgrey guibg=lightgrey
" }
