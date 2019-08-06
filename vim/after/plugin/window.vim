function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr()) "we havent moved
    if (match(a:key,'[jk]')) "were we going up/down
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction

function! ResizeWindow(key) abort
    exe '5wincmd ' . GetDirection(a:key)
endfunction

function! GetDirection(key) abort
    let ei = GetEdgeInfo()
    if get(ei, 'right') && a:key is 'left'
        return '>'
    endif
    if get(ei, 'right') && a:key is 'right'
        return '<'
    endif
    if get(ei, 'up') && a:key is 'up'
        return '-'
    endif
    if get(ei, 'up') && a:key is 'down'
        return '+'
    endif
    if a:key=='left'
        return '<'
    endif
    if a:key=='right'
        return '>'
    endif
    if a:key=='up'
        return '+'
    endif
    if a:key=='down'
        return '-'
    endif

endfunction

function! GetEdgeInfo() abort
  let check_directions = ['up', 'right']
  let result = {}
  for direction in check_directions
    exe 'let result["' . direction . '"] = ' . CanMoveCursorFromCurrentWindow(direction)
  endfor
  return result
endfunction

function! CanMoveCursorFromCurrentWindow(direction) abort
  let map_directions = {'up':'k', 'right':'l'}
  if has_key(map_directions, a:direction)
    let direction = map_directions[a:direction]
  elseif index(values(map_directions), a:direction) != -1
    let direction = a:direction
  endif
  let from = winnr()
  exe "wincmd " . direction
  let to = winnr()
  exe from . "wincmd w"
  return from == to
endfunction
