" Colors
syntax enable           " enable syntax processing

" Spaces and Tabs
set tabstop=4           " number of visual spaces per TAB
set softtabstop=4       " number of spaces in tab when editing
set expandtab           " tabs are spaces
set shiftwidth=4

" UI Config
set relativenumber      " show line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]

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
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>
