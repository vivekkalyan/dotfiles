let g:BowsplinterColorColumnBlacklist = ['diff', 'undotree', 'nerdtree', 'qf', 'filebeagle', 'help']
let g:BowsplinterCursorlineBlacklist = ['command-t']
let g:BowsplinterMkviewFiletypeBlacklist = ['diff', 'hgcommit', 'gitcommit']

function! autocmds#attempt_select_last_file() abort
  let l:previous=expand('#:t')
  if l:previous != ''
    call search('\v<' . l:previous . '>')
  endif
endfunction

function! autocmds#should_colorcolumn() abort
  return index(g:BowsplinterColorColumnBlacklist, &filetype) == -1
endfunction

function! autocmds#should_cursorline() abort
  return index(g:BowsplinterCursorlineBlacklist, &filetype) == -1
endfunction


" Loosely based on: http://vim.wikia.com/wiki/Make_views_automatic
function! autocmds#should_mkview() abort
  return
        \ &buftype == '' &&
        \ index(g:BowsplinterMkviewFiletypeBlacklist, &filetype) == -1 &&
        \ !exists('$SUDO_USER') " Don't create root-owned files.
endfunction

function! autocmds#mkview() abort
  if exists('*haslocaldir') && haslocaldir()
    " We never want to save an :lcd command, so hack around it...
    cd -
    mkview
    lcd -
  else
    mkview
  endif
endfunction
