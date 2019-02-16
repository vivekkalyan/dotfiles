" TODO: use better colors for loupe
function! s:SetUpLoupeHighlight()
  execute 'highlight! QuickFixLine ' . pinnacle#extract_highlight('PmenuSel')

endfunction

if has('autocmd')
  augroup BowSplinterLoupe
    autocmd!
    autocmd ColorScheme * call s:SetUpLoupeHighlight()
  augroup END
endif

call s:SetUpLoupeHighlight()

let g:LoupeHighlightGroup='IncSearch'
