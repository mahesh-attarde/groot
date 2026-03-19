" Disable vi compatibility
set nocompatible

" Enable syntax highlighting and filetype detection
syntax enable
filetype plugin indent on

" Line numbers and cursor position
set number
set ruler
set cursorline

" GUI settings
set guifont=mono\ 14

" Command-line behavior
set showcmd
set showmode
set wildmenu
set wildmode=list:longest
set wildignore+=*.swp

" Editing behavior
set backspace=indent,eol,start
set hidden

" Search settings
set ignorecase
set smartcase
set incsearch
set hlsearch

" Display settings
set wrap
set showmatch

" Tab and indentation
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

" Enable mouse support
set mouse=a
