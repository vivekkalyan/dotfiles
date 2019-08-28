function s:CheckColorScheme()
  set termguicolors
  if !has('termguicolors')
    let g:base16colorspace=256
  endif

  color apprentice

  execute 'highlight Comment ' . pinnacle#italicize('Comment')
  execute 'highlight CursorLineNr ' . pinnacle#embolden('CursorLineNr')

  " Allow for overrides:
  " - `statusline.vim` will re-set User1, User2 etc.
  " - `after/plugin/loupe.vim` will override Search.
  doautocmd ColorScheme
endfunction

if v:progname !=# 'vi'
  if has('autocmd')
    augroup BowsplinterAutocolor
      autocmd!
      autocmd FocusGained * call s:CheckColorScheme()
    augroup END
  endif

  call s:CheckColorScheme()
endif
