setlocal conceallevel=2
setlocal spell

" in insert mode, automatically apply the first suggestion for spelling on the previous word
" <C-g>u: creates a new change sequence for the context of undo (allows for undo to happen on that specific change only)
" `]: mark denoting where the cursor was before making the [s or ]s jumps.
inoremap z= <C-g>u<Esc>[S1z=`]a<C-g>u
