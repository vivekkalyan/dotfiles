" General
set nocompatible        " remove vi compatibility
set encoding=utf-8      " set vim encoding
set scrolloff=3         " minimum lines to keep in view around cursor
set backspace=indent,eol,start  " backspace works in normal mode
set laststatus=2        " show file name in status bar

set path+=**            " search down into subfolders for files
set wildmenu            " command-line completion
set wildmode=longest:list,full  " cycle between command line completions

let mapleader = ','     " map leader key to ,

" Colors
syntax enable           " enable syntax processing
filetype plugin on      " run scripts based on type of file

" Spaces and Tabs
set tabstop=4           " number of visual spaces per TAB
set softtabstop=4       " number of spaces in tab when editing
set expandtab           " tabs are spaces
set shiftwidth=4        " number of spaces in (auto)indent
set autoindent          " follow indentation of previous line

" UI Config
set relativenumber      " show relative line numbers
set number              " ... except for current line
set showcmd             " show command in bottom bar
set showmode            " show mode in bottom bar
set cursorline          " highlight current line
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]
set wrap                " wrap text
set textwidth=79        " characters to wrap text at

" Searching 
set ignorecase          " Ignore case when typing
set smartcase           " ... unless we type a capital
set gdefault            " Apply subsititutions globally
set incsearch           " Incremental searching
set hlsearch            " Highlight matches when searching

" Remove distracting highlight after finding what we searched
nnoremap <leader><space> :noh<cr>   
" Use tab to do matching search
nnoremap <tab> %        
vnoremap <tab> %
" Turn off vim's custom regex
nnoremap / /\v
vnoremap / /\v

" Movement
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

" NERDTree
" close NERDTree after a file is opened
let g:NERDTreeQuitOnOpen=0
" show hidden files in NERDTree
let NERDTreeShowHidden=1
" Toggle NERDTree
nmap <silent> <leader>k :NERDTreeToggle<cr>
" expand to the path of the file in the current buffer
nmap <silent> <leader>y :NERDTreeFind<cr>
