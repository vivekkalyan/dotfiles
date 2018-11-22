function s:CheckColorScheme()
  if !has('termguicolors')
    let g:base16colorspace=256
  endif

  set background=dark
  color base16-tomorrow-night

  " execute 'highlight Comment ' . pinnacle#italicize('Comment')

  " Hide (or at least make less obvious) the EndOfBuffer region
  highlight! EndOfBuffer ctermbg=bg ctermfg=bg guibg=bg guifg=bg

  " Sync with corresponding non-nvim settings in ~/.vim/plugin/settings.vim:
  highlight clear NonText
  highlight link NonText Conceal
  highlight clear CursorLineNr
  highlight link CursorLineNr DiffText
  highlight clear VertSplit
  highlight link VertSplit LineNr

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
