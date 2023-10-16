local opts = { noremap = true, silent = true }
local remap_opts = { silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }
local remap_expr_opts = { silent = true, expr = true }

local keymap = vim.keymap.set

--Remap SPACE as leader key
vim.g.mapleader = " "

-- H/L to move to start/end of sentences
keymap("n", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("v", "L", "g_", opts)

-- turn off vim's custom regex
-- keymap("n", "/", "/\\v", opts)
-- keymap("v", "/", "/\\v", opts)

-- Yank to end of line
keymap("n", "Y", "y$", opts)

-- Split lines (opposite of shift-J)
keymap("n", "<S-s>", ":keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==<CR>", opts)

-- Play macro
keymap("n", "Q", "@q", opts)

-- Enter to enter command mode (& disable for command window to allow q:, q/)
keymap("n", "<CR>", ":", opts)
vim.api.nvim_create_autocmd(
  { "BufReadPost" },
  { pattern = { "quickfix" }, command = "nnoremap <buffer> <CR> <CR>" }
)
vim.api.nvim_create_autocmd(
  { "CmdwinEnter" },
  { pattern = { "*" }, command = "nnoremap <buffer> <CR> <CR>" }
)

-- Clear search with <esc>
keymap("n", "<esc>", "<cmd>noh<cr><esc>", opts)

-- Save file
keymap("n", "<C-s>", "<cmd>w<cr><esc>", opts)
keymap("i", "<C-s>", "<cmd>w<cr><esc>", opts)
keymap("v", "<C-s>", "<cmd>w<cr><esc>", opts)

-- C-j/k to move down/up paragraph
keymap("n", "<C-j>", "(search('^\\n.', 'Wen') - line('.')) . 'jzv^'", expr_opts)
keymap("n", "<C-k>", "(line('.') - search('^\\n.\\+$', 'Wenb')) . 'kzv^'", expr_opts)

-- Move by visual line rather than physical line
-- Move correctly when text is wrapped and using {count}j/k
keymap("n", "j", function()
  if vim.v.count then
    return "j"
  else
    return "gj"
  end
end, expr_opts)
keymap("n", "k", function()
  if vim.v.count then
    return "k"
  else
    return "gk"
  end
end, expr_opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Terminal-like experience for command line
keymap("c", "<C-a>", "<Home>", opts)
keymap("c", "<C-e>", "<End>", opts)

-- window
local status_ok, window = pcall(require, "vivek.window")
if status_ok then
  keymap("n", "<C-w>h", "<cmd> lua require('vivek.window').win_move('h')<cr>", opts)
  keymap("n", "<C-w>j", "<cmd> lua require('vivek.window').win_move('j')<cr>", opts)
  keymap("n", "<C-w>k", "<cmd> lua require('vivek.window').win_move('k')<cr>", opts)
  keymap("n", "<C-w>l", "<cmd> lua require('vivek.window').win_move('l')<cr>", opts)

  keymap("n", "<C-left>", "<cmd> lua require('vivek.window').resize_win('left')<cr>", opts)
  keymap("n", "<C-down>", "<cmd> lua require('vivek.window').resize_win('down')<cr>", opts)
  keymap("n", "<C-up>", "<cmd> lua require('vivek.window').resize_win('up')<cr>", opts)
  keymap("n", "<C-right>", "<cmd> lua require('vivek.window').resize_win('right')<cr>", opts)
end
