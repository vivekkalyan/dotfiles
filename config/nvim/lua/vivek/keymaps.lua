local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true}

local keymap = vim.keymap.set

--Remap , as leader key
vim.g.mapleader = ","


-- H/L to move to start/end of sentences
keymap("n", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("v", "L", "g_", opts)

-- turn off vim's custom regex
-- keymap("n", "/", "/\\v", opts)
-- keymap("v", "/", "/\\v", opts)

-- Open File Explorer
keymap("n", "<leader>e", ":Lex 30<cr>", opts)

-- Yank to end of line
keymap("n", "Y", "y$", opts)

-- Split lines (opposite of shift-J)
keymap("n", "<S-s>", ":keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==<CR>", opts)

-- Play macro
keymap("n", "Q", "@q", opts)

-- Enter to enter command mode (& disable for command window to allow q:, q/)
keymap("n", "<CR>", ":", opts)
vim.api.nvim_create_autocmd(
    { "BufReadPost"},
    { pattern = { "quickfix" }, command = "nnoremap <buffer> <CR> <CR>"}
)
vim.api.nvim_create_autocmd(
    { "CmdwinEnter"},
    { pattern = { "*" }, command = "nnoremap <buffer> <CR> <CR>"}
)

-- C-j/k to move down/up paragraph
keymap("n", "<C-j>", "(search('^\\n.', 'Wen') - line('.')) . 'jzv^'", expr_opts)
keymap("n", "<C-k>", "(line('.') - search('^\\n.\\+$', 'Wenb')) . 'kzv^'", expr_opts)

-- Move by visual line rather than physical line
-- Move correctly when text is wrapped and using {count}j/k
keymap("n", "j", function()
    if vim.v.count then return "j" else return "gj" end
end, expr_opts)
keymap("n", "k", function()
    if vim.v.count then return "k" else return "gk" end
end, expr_opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Terminal-like experience for command line
keymap("c", "<C-a>", "<Home>", opts)
keymap("c", "<C-e>", "<End>", opts)
