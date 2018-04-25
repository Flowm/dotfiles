" README {
" vim: set foldmarker={,} foldlevel=0:
"
"	This is my personal vim configuration. As quite a lot of effort went into
"	it, I would be glad if this was useful for anybody else than me.
"
"	Feel free to ask question or reuse any useful parts.
"
"	I also periodically sync my current vimrc to Github, so feel free to grab
"	the current version from there:
"		https://github.com/Flowm/dotfiles/blob/master/home/.vimrc
" }

" Basic {
		"Use vim defaults
	set nocompatible
		"Disable filetype detection during init
	filetype off
		"Enable Syntax highlighting
	syntax enable
		"Explicitly define xterm as environment
	behave xterm
		"More screen updates
	set ttyfast
		"Disable modelines
	set nomodeline
		"No exec
	set secure
		"Encoding
	set encoding=utf-8
		"Remove splash screen
	set shortmess+=I
		"Function of the backspace key
	set backspace=indent,eol,start
" }

" Vundle with automatic setup {
	let iCanHazVundle=1
	let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
	if !filereadable(vundle_readme)
		echo "Installing Vundle..."
		echo ""
		silent !mkdir -p ~/.vim/bundle
		silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
		let iCanHazVundle=0
	endif
	set rtp+=~/.vim/bundle/vundle
	call vundle#begin()

	Plugin 'gmarik/vundle'

	Plugin 'vim-airline/vim-airline'
	Plugin 'vim-airline/vim-airline-themes'
	Plugin 'altercation/vim-colors-solarized'
	Plugin 'scrooloose/nerdcommenter'
	Plugin 'scrooloose/nerdtree'
	Plugin 'jistr/vim-nerdtree-tabs'
	Plugin 'benmills/vimux'
	Plugin 'airblade/vim-gitgutter'
	Plugin 'tpope/vim-fugitive'
	Plugin 'Lokaltog/vim-easymotion'
	Plugin 'vim-scripts/ReplaceWithRegister'
	Plugin 'scrooloose/syntastic'
	Plugin 'sheerun/vim-polyglot'
	Plugin 'ctrlpvim/ctrlp.vim'
	Plugin 'majutsushi/tagbar'
	Plugin 'powerman/vim-plugin-AnsiEsc'
	Plugin 'loremipsum'
	if hostname() == "flake" || hostname() == "app"
		Plugin 'Valloric/YouCompleteMe'
	endif
	if hostname() != "spirit"
		Plugin 'editorconfig/editorconfig-vim'
	endif

	if iCanHazVundle == 0
		echo "Installing Bundles, please ignore key map error messages"
		echo ""
		:BundleInstall
	endif

	call vundle#end()
	filetype plugin indent on
" }

" General {
	" Backup and temporary files {
		set backup
		set backupdir=~/.myconf/tmp/.vimbak
		set directory=~/.myconf/tmp/.vimtmp,.
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
			"Start searching with the first character
		set incsearch
			"Ignore case
		set ignorecase
			"Match case if searchstring starts with uppercase
		set smartcase
			"Global search by default
		set gdefault
			"Treat more characters as special (like in perl) when searching (e.g. . *)
		set magic
	" }
	" Spelling {
		set spelllang=en,de
	" }
	" Misc {
			" Only one whitespace after _J_oining after a dot
		set nojoinspaces
			" Disable autoselection of vim clipboard
		set clipboard-=autoselect
		set guioptions-=a
			" Use the best available cryptmethod
		if has("patch-7.4.399")
			set cryptmethod=blowfish2
		endif
	" }
" }

" Appearance and handling {
	" Theme {
			" Use a portable version of solarized in all terminals except iterm
		if $LC_TERM != 'iterm'
			let t_Co=256
			let g:solarized_termcolors=256
		endif
			" Set colorscheme to solarized
		colorscheme solarized
			" Use the dark version of solarized
		set background=dark
	" }
	" Color tweaks {
		"hi Search ctermbg=DarkYellow ctermfg=White
		"hi Identifier ctermfg=6 cterm=bold
			" 0 black, 1 darkred, 2 darkgreen, 3 darkyellow, 4 darkblue, 5 darkmagenta, 6 darkcyan, 7 grey
			" Non-safe Colors, 16-Color-Term:
			" darkgrey, lightblue, lightgreen, lightcyan, lightred, lightmagenta, " lightyellow, white
	" }
	" Statusbar {
			"Renaming xterm window
		set title
			"Don't show line numbers
		set nonumber
			"Always show the status bar
		set laststatus=2
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
			"Search tags file in current dir and all parent dir
		set tags=./tags;/
	" }
" }

" Text Formatting/Layout {
	" Whitespace and Tab display {
		set nolist
		set listchars=tab:»\ ,nbsp:␣,trail:·,extends:›,precedes:‹
		"hi SpecialKey ctermbg=4
	" }
	" Overlong lines display {
			"Don't do newlines automatically
		set fo-=t
			"Scroll right by default instead of breaking the line
		set nowrap
			"Don't stat a new line automatically break lines
		set wrapmargin=0
			"But continue with a mark in the next line
		set showbreak=>>>
	" }
	" Indention {
			"One Tab per indentation level. 4 column wide Tabs.
			"Intelligently detect current indention level
		set autoindent
			"Size of real Tabs
		set tabstop=4
			"Indent amount when using TAB
		set softtabstop=4
			"Indent amount when using cindent, >>, ..
		set shiftwidth=4
			"Do not expand tabs to spaces
		set expandtab
	" }
	" Indention shortcuts {
		nmap \t :set noexpandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
		nmap \T :set noexpandtab tabstop=8 shiftwidth=4 softtabstop=4<CR>
		nmap \s :set expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
		nmap \S :set expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>
	" }
	" Folding (disabled) {
			"Disable folding completely
		"set nofoldenable
			"Disable folding in the initial view
		set foldlevel=40
			"Make folding indent sensitive
		set foldmethod=indent
	" }
" }

" Mappings and functions {
	" Misc {
			"Easier escape
		inoremap jj <ESC>
		inoremap ,, <ESC>
			"Match brackets key
		nnoremap <tab> %
		vnoremap <tab> %
			"Search for selected text in visual mode with //
		vnoremap // y/\V<C-R>"<CR>
			"Clear highlight
		map <silent> <C-l> :silent nohl<CR>
			"Save as root
		cmap w!! %!sudo tee > /dev/null %
			"Single line diffput and diffget
		vnoremap <silent> dp :diffput<cr>:diffupdate<cr>
		vnoremap <silent> dg :diffget<cr>:diffupdate<cr>
	" }
	" Custom Keyset {
		let mapleader = ","
			"Reselect just pasted content
		nnoremap <leader>v V`]
			"Split Window and switch over to it
		nnoremap <leader>w <C-w>v<C-w>l
		nnoremap <leader>w <C-w>h<C-w>l
	" }
	" C&P between files via a tempfile {
			"Copy to buffer
		vnoremap <leader>y :w! ~/.myconf/tmp/.vimbak/vimbuffer<CR>
		nnoremap <leader>y :.w! ~/.myconf/tmp/.vimbak/vimbuffer<CR>
			"Paste from buffer
		nnoremap <leader>p :r ~/.myconf/tmp/.vimbak/vimbuffer<CR>
		nnoremap <leader>P :-r ~/.myconf/tmp/.vimbak/vimbuffer<CR>
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
	" Functions {
		" Toggle background {
			function ToggleSolarizedBackground()
				if &background == 'dark'
					set background=light
					colorscheme solarized
				else
					set background=dark
					colorscheme solarized
				endif
			endfunction
		" }
		" Toggle the arrow keys {
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
		" }
		" Toggle whitespace and tab display {
			function ToggleList()
				if &list
					set nolist
				else
					set list
				endif
			endfunction
		" }
		" Toggle visual highlighting of lines longer than 80 chars {
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
		" }
		" Toggle line numbers {
			function ToggleNumber()
				if &number
					set norelativenumber
					set nonumber
				else
					set norelativenumber
					set number
				endif
			endfunction
		" }
		" Toggle relative line numbers {
			function ToggleRelNumber()
				if &relativenumber
					set nonumber
					set norelativenumber
				else
					set number
					set relativenumber
				endif
			endfunction
		" }
		" Toggle line wrap {
			function ToggleWrap()
				if &wrap
					set nowrap
				else
					set wrap
				endif
			endfunction
		" }
	" }
	" Function Keys {
		" Handling:
		" <F2> Toggle git diff cloumn
			map <silent><F2> :GitGutterToggle <CR>
		" <L-F2> Toggle git diff line highlighting
			map <silent><leader><F2> :GitGutterLineHighlightsToggle <CR>
		" <F3> Toggle the arrow keys
			map <silent><F3> :call ToggleArrowKeys() <CR>
		" <F4> Toggle paste mode
			set pastetoggle=<F4>

		" Design:
		" <F5> Toggle whitespace and tab display
			map <silent><F5> :call ToggleList() <CR>
		" <L-F5> Toggle visual highlighting of lines longer than 80 chars
			map <silent><leader><F5> :call ToggleColorColumn() <CR>
		" <F6> Toggle line numbers
			map <silent><F6> :call ToggleNumber() <CR>
		" <L-F6> Toggle relative line numbers
			map <silent><leader><F6> :call ToggleRelNumber() <CR>
		" <F7> Toggle line wrap
			map <silent><F7> :call ToggleWrap() <CR>
		" <F8> Toggle background
			map <silent><F8> :call ToggleSolarizedBackground() <CR>

		" Features:
		" <F9> Toggle spell checking
			map <silent><F9> :set spell!<CR><Bar>:echo 'Spell check: ' . strpart('OffOn', 3 * &spell, 3)<CR>
		" <F10> vimux RunCommand make
			map <silent><F10> :VimuxRunCommand("make") <CR>
		" <L-F10> vimux RunCommandPromt
			map <silent><leader><F10> :VimuxPromptCommand <CR>
		" <F11> Display all custom keybindings
			map <silent><F12> :!egrep '" <([LS]-)?F[1-9][0-2]?> ' ~/.vimrc <CR>

		" Leader mapping:
		" <L-m> VimuxRunLastCommand
			map <silent><leader>m :VimuxRunLastCommand <CR>
		" <L-M> VimuxPromptCommand
			map <silent><leader>M :VimuxPromptCommand <CR>
	" }
" }
" Settings for addons {
	" vim-gitgutter {
		let g:gitgutter_enabled = 0
		highlight SignColumn ctermfg=239 ctermbg=235 guifg=Yellow
		highlight GitGutterAdd ctermfg=2 ctermbg=235 guifg=#009900
		highlight GitGutterChange ctermfg=3 ctermbg=235 guifg=#bbbb00
		highlight GitGutterDelete ctermfg=1 ctermbg=235 guifg=#ff2222
		nmap <leader>j <Plug>GitGutterNextHunk<CR>
		nmap <leader>k <Plug>GitGutterPrevHunk<CR>
		" Decrease amount of executions
		"let g:gitgutter_eager = 0
	" }
	" Airline {
		let g:airline_theme='solarized'
	" }
	" vimux {
		"let g:VimuxOrientation = "h"
		"let g:VimuxHeight = "40"
	" }
	" NERDtree {
		nmap <leader>n <Plug>NERDTreeTabsToggle<CR>
		let g:NERDTreeQuitOnOpen = 0
		let g:nerdtree_tabs_open_on_gui_startup = 0
	" }
	" Tagbar {
		nnoremap <silent> <leader>b :TagbarToggle<CR>
	" }
	" syntastic {
		let g:syntastic_cpp_compiler_options = '-std=c++11'
		let g:syntastic_arduino_checkers=['']
		let g:syntastic_quiet_messages = {
			\ "!level": "errors" }
	" }
	" YouCompleteMe {
		"let g:loaded_youcompleteme = 1
	" }
" }

" Conditionals {
	if has('autocmd')
		augroup testgroup
		autocmd!
		" Filetype detection {
			au BufRead,BufNewFile Vagrantfile* set ft=ruby
			au BufRead,BufNewFile *.grub set ft=cfg
			au BufRead,BufNewFile *.ts set ft=typescript
		" }
		" Filetype settings {
			"au FileType ruby	set tabstop=2 softtabstop=2 shiftwidth=2 expandtab smarttab
		" }
		" Other dev {
			au BufRead,BufNewFile *.README set textwidth=72
			au BufRead,BufNewFile *aegis-* set textwidth=72
			au BufRead,BufNewFile *_eternal_history set tabstop=8
		" }
		augroup END
	endif
	" Host based indention settings {
	if hostname() == "dev"
		set cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
		set shiftwidth=2
		set tabstop=8
	endif
" }

" To be tested/integrated {
" }
