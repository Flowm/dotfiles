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
		"Use Vim defaults
	set nocompatible
		"Pantogen is used to manage vim plugins
	call pathogen#infect()
	call pathogen#helptags()
	syntax enable
	filetype plugin indent on
		"Explicitly define xterm as environment
	behave xterm
		"More screen updates
	set ttyfast
		"No modeline for security
	set nomodeline
		"No exec
	set secure
		"Encoding
	"set encoding=utf-8
		"Function of the backspace key
	set backspace=indent,eol,start
" }

" General {
	" Backup and TMP Files {
		set backup
		set backupdir=~/.tmp/.vimbak
		set directory=~/.tmp/.vimtmp,.
		set history=2048
		set undolevels=2048
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
	" Misc {
		" Only one whitespace after _J_oining after a dot
		set nojoinspaces
		" Disable autoselection of vim Clipboard
		set clipboard-=autoselect
		set guioptions-=a
	" }
" }

" Appearance and handling {
	" Theme {
		"colorscheme evening
		let g:solarized_termcolors=256
		colorscheme solarized
		set background=dark
	" }
	" Colors {
		hi Search ctermbg=DarkYellow ctermfg=White
		" Used by listchars
		hi SpecialKey ctermbg=1

		" Some tweaks for the solarized colorscheme
		hi Identifier ctermfg=6 cterm=bold
		" 0 black, 1 darkred, 2 darkgreen, 3 darkyellow, 4 darkblue, 5 darkmagenta, 6 darkcyan, 7 grey
		" Non-safe Colors, 16-Color-Term:
		" darkgrey, lightblue, lightgreen, lightcyan, lightred, lightmagenta, " lightyellow, white
		"
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
		function RefreshStatusline()
				"Clear the statusline
			set statusline=
				"Tail of the filename
			set statusline=%t\ 
				"Complete filename
			"set statusline=%f\ 
			if winwidth(0) > 65 
					"File format
				set statusline+=[%{&fileformat},
					"File encoding
				set statusline+=%{strlen(&fenc)?&fenc:&enc}]
					"Flag
				set statusline+=%m%r%h%w
					"Filetype
				set statusline+=[%Y]
					"Filetype
				set statusline+=[%{&fo}]
			endif
			if winwidth(0) > 80
					"Last modified
				set statusline+=%20(%{strftime(\"%d/%m/%y\ -\ %H:%M\")}%)
			endif
				"Left/Right separator
			set statusline+=%=
			if winwidth(0) > 95
					"Current module name
				set statusline+=%{synIDattr(synID(line('.'),col('.'),1),'name')}\ 
			endif
				"HEX value of char
			"set statusline+=[HEX:0x%2B]\ 
				"ASCII value of char
			"set statusline+=[ASCII:%3b]\ 
				"COL + LIN
			set statusline+=%-20([COL:%2v][LIN:%3l/%L]%)\ 
				"Percentage of file
			set statusline+=[%3p%%]
			endfunction
		call RefreshStatusline()
	" }
	" Misc Handling {
			"Always let 5 lines below and above the cursor on the screen
		set scroll=11
		set scrolloff=5
		set sidescroll=8
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
		set nolist
		"set list listchars=tab:>.,trail:.
		set listchars=tab:\ \ ,trail:\.
		"set list listchars=tab:>.,trail:·
	" }
	" Overlong lines display {
			"Don't do newlines automatically
		set fo-=t
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
			"set nofoldenable
			"Make folding indent sensitive
		set foldmethod=indent
		set foldlevel=40
	" }
" }

" Mappings and functions {
	" Misc {
			"Easier escape
		inoremap <F1> <ESC>
		nnoremap <F1> <ESC>
		vnoremap <F1> <ESC>
		inoremap jj <ESC>
		inoremap ,, <ESC>
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
			"Update the Statusline
		nnoremap <leader>; :call RefreshStatusline() <CR>
	" }
	" C&P between files via bufer {
			"Copy to buffer
		vnoremap <leader>y :w! ~/.tmp/.vimbak/vimbuffer<CR>
		nnoremap <leader>y :.w! ~/.tmp/.vimbak/vimbuffer<CR>
			"Paste from buffer
		nnoremap <leader>p :r ~/.tmp/.vimbak/vimbuffer<CR>
		nnoremap <leader>P :-r ~/.tmp/.vimbak/vimbuffer<CR>
	" }
	" Disable arrow keys by default {
		nnoremap <up> <nop>
		nnoremap <down> <nop>
		nnoremap <left> <nop>
		nnoremap <right> <nop>
		inoremap <up> <nop>
		inoremap <down> <nop>
		inoremap <left> <nop>
		inoremap <right> <nop>
		"nnoremap j gj
		"nnoremap k gk
	" }
	" Syntax checking {
		map <leader>spl :w !perl -c %<CR>
		map <leader>srb :w !ruby -c %<CR>
		map <leader>sgcc :w !gcc -fsyntax-only %<CR>
		map <leader>sjava :w !javac %<CR>
	" }
	" Reminders {
		"+y (copy)
		"+x (cut)
		"+p (paste)
	" }
	" <F1>-<F9> {
		" <F1> Paste to grave.io {
			map <F1> :w !bury -t % <CR>
		" }
		" <F2> Toggle paste mode {
			map <silent> <F2> :GitGutterToggle <CR>
		" }
		" <F3> Toggle paste mode {
			map <silent> <F3> :GitGutterLineHighlightsToggle <CR>
		" }
		" <F4> Toggle the arrow keys {
			function ToggleArrowKeys()
				if !exists('s:arrow_keys')
					unmap <up>
					unmap <down>
					unmap <left>
					unmap <right>
					let s:arrow_keys = 1
				else
					nnoremap <up> <nop>
					nnoremap <down> <nop>
					nnoremap <left> <nop>
					nnoremap <right> <nop>
					inoremap <up> <nop>
					inoremap <down> <nop>
					inoremap <left> <nop>
					inoremap <right> <nop>
					unlet s:arrow_keys
				endif
			endfunction
			map <silent> <F4> :call ToggleArrowKeys() <CR>
		" }
		" <F5> Toggle paste mode {
			set pastetoggle=<F5>
		" }
		" <F6> Toggle whitespace and tab display {
			function ToggleList()
				if &list
					set nolist
				else
					set list
				endif
			endfunction
			map <silent> <F6> :call ToggleList() <CR>
		" }
		" <F7> Toggle visual highlighting of lines longer than 80 chars {
			function ToggleColorColumn()
				if exists('+colorcolumn')
					if empty(&colorcolumn)
						highlight ColorColumn ctermbg=red
						if empty(&textwidth)
							set colorcolumn=81
						else
							set colorcolumn=+1
						endif
					else
						set colorcolumn=
					endif
				else
					if !exists('s:color_column')
						highlight OverLength ctermbg=red ctermfg=white
						match OverLength /\%81v.\+/
						let s:color_column = 1
					else
						match OverLength //
						unlet s:color_column
					endif
				endif
			endfunction
			map <silent> <F7> :call ToggleColorColumn() <CR>
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
		" <F9> Toggle spell checking {
			map <F9> :set spell!<CR><Bar>:echo 'Spell check: ' . strpart('OffOn', 3 * &spell, 3)<CR>
		" }
	" }
	" Window functions {
	" }
" }
" Settings for addons {
	" perl.vim {
		let g:Perl_GlobalTemplateFile=$HOME.'/.vim/bundle/perl-support.vim/perl-support/templates/Templates'
		let perl_want_scope_in_variables = 1
		let perl_extended_vars = 1
		let perl_string_as_statement = 1
	" }
	" vim-gitgutter {
		let g:gitgutter_enabled = 0
		highlight SignColumn ctermfg=239 ctermbg=235 guifg=Yellow
		highlight GitGutterAdd ctermfg=2 ctermbg=235 guifg=#009900
		highlight GitGutterChange ctermfg=3 ctermbg=235 guifg=#bbbb00
		highlight GitGutterDelete ctermfg=1 ctermbg=235 guifg=#ff2222
		nmap <leader>j <Plug>GitGutterNextHunk
		nmap <leader>k <Plug>GitGutterPrevHunk
		" Decrease amount of executions
		"let g:gitgutter_eager = 0
	" }
" }

" Conditionals {
	if has('autocmd')
		" Filetype Detection {
			au BufRead,BufNewFile *.gui set ft=perl
			au BufRead,BufNewFile *.ino,*.pde set ft=arduino
		" }
		" Filetype settings {
			au FileType ruby	set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab
			au FileType perl	set tabstop=8 softtabstop=4 shiftwidth=4 noexpandtab smarttab shiftround
			au FileType arduino	set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
		    au FileType html	set tabstop=4 shiftwidth=4 nosmarttab autoindent
		" }
		" Other dev {
			au BufRead,BufNewFile *.README set textwidth=72
			au BufRead,BufNewFile *aegis-* set textwidth=72
		" }
	endif
" }

" To be tested/integrated {
	"set confirm
	"au FocusLost * :wa
	"hi ColorColumn ctermbg=lightgrey guibg=lightgrey
	"set statusline+=[%{winnr()}]
	"set statusline+=[%{winwidth(0)}]
	" HTML encode all vowels with Strg-H {
		"function HtmlEscape()
		"	silent s/ö/\&ouml;/eg
		"	silent s/ä/\&auml;/eg
		"	silent s/ü/\&uuml;/eg
		"	silent s/Ö/\&Ouml;/eg
		"	silent s/Ä/\&Auml;/eg
		"	silent s/Ü/\&Uuml;/eg
		"	silent s/ß/\&szlig;/eg
		"endfunction
		"map <silent> <c-h> :call HtmlEscape()<CR>
	" }
" }
