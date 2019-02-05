" General
set nocompatible        " remove vi compatibility
set encoding=utf-8      " set vim encoding
set scrolloff=3         " minimum lines to keep in view around cursor
set backspace=indent,eol,start  " backspace works in normal mode
set laststatus=2        " show file name in status bar

set path+=**            " search down into subfolders for files
set wildignore+=**/node_modules/**  " ignore folders
set wildmenu            " command-line completion
set wildmode=longest:list,full  " cycle between command line completions

let mapleader = ','     " map leader key to ,

" Colors
syntax enable           " enable syntax processing
filetype plugin indent on      " run scripts based on type of file

" Formating
set tabstop=4           " number of visual spaces per TAB
set softtabstop=4       " number of spaces in tab when editing
set expandtab           " tabs are spaces
set shiftwidth=4        " number of spaces in (auto)indent
set autoindent          " follow indentation of previous line
set shiftround          " always indent by multiple of shiftwidth
set nojoinspaces        " don't autoinsert two spaces after '.', '?', '!' for join command
set formatoptions+=j    " remove comment leader when joining comment lines
set formatoptions+=n    " smart auto-indenting inside numbered lists

" Folding
set foldenable          " enable folding
set foldlevelstart=0    " close all folds by default (learning)
set foldmethod=indent   " fold based on indent level

" UI Config
set relativenumber      " show relative line numbers
set number              " ... except for current line
set showcmd             " show command in bottom bar
set showmode            " show mode in bottom bar
set cursorline          " highlight current line
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]
set wrap                " wrap text
set breakindent         " indent wrapped lines to match start
set textwidth=80        " characters to wrap text at
set highlight+=@:ColorColumn    " ~/@ at end of window, 'showbreak'
set highlight+=N:DiffText       " make current line number stand out a little
set highlight+=c:LineNr         " blend vertical separators with line numbers
set list                " show whitespace
set listchars=tab:▷┅    " WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7)
                        " + BOX DRAWINGS HEAVY TRIPLE DASH HORIZONTAL (U+2505,
                        " UTF-8: E2 94 85)
set listchars+=trail:•  " BULLET (U+2022, UTF-8: E2 80 A2)

" Windows
set splitbelow          " open horizontal split below current window
set splitright          " open vertical split to the right of current window
set switchbuf=usetab    " try to reuse windows/tabs when switching buffers
set hidden              " allow switching modified buffers
set fillchars=vert:┃    " solid line to seperate windows
set fillchars+=stlnc:=  " fill inactive status lines with '='

" Searching
set ignorecase          " Ignore case when typing
set smartcase           " ... unless we type a capital
set gdefault            " Apply subsititutions globally
set incsearch           " Incremental searching
set hlsearch            " Highlight matches when searching

" Make ctags
command! MakeTags !ctags -R .

" space open/closes folds
nnoremap <space> za

" Remove distracting highlight after finding what we searched
nnoremap <leader>n :noh<cr>
" Use tab to do matching search
nnoremap <tab> %
vnoremap <tab> %
" Turn off vim's custom regex
" nnoremap / /\v
" vnoremap / /\v

" Movement
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
" Move by visual line rather than physical line
nnoremap j gj
nnoremap k gk
" Move correctly when text is wrapped and using {count}j/k
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Command Mode
" Terminal-like experience for command line
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" `<Tab>`/`<S-Tab>` to move between matches without leaving incremental search.
" Note dependency on `'wildcharm'` being set to `<C-z>` in order for this to
" work.
set wildcharm=<C-z>

cnoremap <expr> <Tab> getcmdtype() == '/' \|\| getcmdtype() == '?' ? '<CR>/<C-r>/' : '<C-z>'
cnoremap <expr> <S-Tab> getcmdtype() == '/' \|\| getcmdtype() == '?' ? '<CR>?<C-r>/' : '<S-Tab>'

" Visual mode
xnoremap <C-h> <C-w>h
xnoremap <C-j> <C-w>j
xnoremap <C-k> <C-w>k
xnoremap <C-l> <C-w>l

" Save temporary/backup files not in the local directory, but in your ~/.vim
" directory, to keep them out of git repos.
" But first mkdir backup, swap, view and undo first to make this work
call system('mkdir ~/.vim')
call system('mkdir ~/.vim/backup')
call system('mkdir ~/.vim/swap')
call system('mkdir ~/.vim/view')
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set viewdir=~/.vim/view//
set viewoptions=cursor,folds

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    call system('mkdir ~/.vim/undo')
    set undodir=~/.vim/undo//
    set undofile
    set undolevels=1000
    set undoreload=10000
endif

" Vim Plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'wincent/loupe'
Plug 'wincent/scalpel'
Plug 'wincent/pinnacle'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'justinmk/vim-sneak'
Plug 'airblade/vim-gitgutter'
call plug#end()

" NERDTree
" close NERDTree after a file is opened
let g:NERDTreeQuitOnOpen=1
" show hidden files in NERDTree
let NERDTreeShowHidden=1
" remove ? for help
let NERDTreeMinimalUI = 1
" keep alts and keep jumps when opening nerdtree
let g:NERDTreeCreatePrefix='silent keepalt keepjumps'
" remove ^G as files prefix (replace with no-break space)
let g:NERDTreeNodeDelimiter = "\u00a0"
" Toggle NERDTree
nmap <silent> <leader>k :NERDTreeToggle<cr>
" expand to the path of the file in the current buffer
nmap <silent> <leader>y :NERDTreeFind<cr>
" Move up a directory using "-" like vim-vinegar (usually "u" does this).
nmap <buffer> <expr> - g:NERDTreeMapUpdir
nnoremap <silent> - :silent edit <C-R>=empty(expand('%')) ? '.' : fnameescape(expand('%:p:h'))<CR><CR>
function! SelectAlternateFileInNERDTree() 
    let l:previous=expand('#:t')
    if l:previous != ''
        call search('\v<' . l:previous . '>')
    endif
endfunction
augroup NERDTreeConfigGroup
    " Clear all existing autocommands in this group
    autocmd!
    autocmd User NERDTreeInit call SelectAlternateFileInNERDTree()
augroup end

" Scalpel
nmap c* <Plug>(Scalpel)

" Loupe
let g:LoupeHighlightGroup='IncSearch'
let g:LoupeCenterResults=1

" vim-gutter
set updatetime=100  " refresh rate
