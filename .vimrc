" Settings
set hlsearch
set incsearch
set laststatus=2
set list
set modified
set nocompatible
set notitle
set ruler
set scroll=11
set scrolloff=5
"set shellcmdflag=-ic
set shiftwidth=8
set showbreak=>>
set showcmd
set showmatch
set smartindent
set tabstop=4
set textwidth=0
set visualbell
set wildmenu
set wildmode=longest,list
"set wm=1
set wrapmargin=2
if version >= 700
	set spelllang=en_us,de_de
endif

" Syntax off fuer babel.pl
au BufNewFile,BufReadPre *babel.pl	filetype plugin off
au BufNewFile,BufReadPre *babel.pl	syn off
" User Perl syntax highlighting for .gui files
au BufNewFile,BufRead *.gui set ft=perl
" Abbreviation for bugzilla link in aeca
au BufNewFile,BufRead *aegis-*	iabbrev buglink http://bugzilla.genua.de/show_bug.cgi?id
au BufNewFile,BufRead *aegis-*	set textwidth=72
au BufNewFile,BufRead *aegis-*	set formatprg=sed\ 's/\\\\n\\\\//g'\|fmt\|sed\ 's/$/\\\\n\\\\/'
" Textwidth for READMEs
au BufNewFile,BufRead *.README set textwidth=72

" Listchars auf Leerzeichen und Grau als Hintergrundfarbe einstellen
set listchars=tab:>.,trail:.
"set listchars=tab:\ \ ,trail:\ 

filetype plugin on
filetype indent on
set ttyfast
syntax on
behave xterm

colorscheme evening
set background=dark
" set foldmethod=syntax

" Einstellungen fuer LaTeX
" let g:tex_fold_enabled = 1
let g:tex_flavor = 'latex'

" Einstellungen fuer perl-support.vim
let g:Perl_AuthorName = 'Florian Mauracher'
let g:Perl_AuthorRef  = 'FM'
let g:Perl_Email      = 'florian.mauracher@genua.de'
let g:Perl_Company    = 'GeNUA Gesellschaft für Netzwerk - und Unix-Administration mbH'

" Einstellungen fuer perl.vim
let perl_want_scope_in_variables = 1
let perl_extended_vars = 1
let perl_want_scope_in_variables = 1
let perl_string_as_statement = 1
