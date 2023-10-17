-- Set leader to SPACE
vim.g.mapleader = " "

-- For conciseness
local keymap = vim.keymap.set

-- H/L to move to start/end of sentences
keymap("n", "H", "^", { silent = true })
keymap("n", "L", "$", { silent = true })
keymap("v", "L", "g_", { silent = true })

-- Yank to end of line
keymap("n", "Y", "y$", { silent = true })

-- Split lines (opposite of shift-J)
keymap(
  "n",
  "<S-s>",
  ":keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==<CR>",
  { silent = true }
)

-- Play macro
keymap("n", "Q", "@q", { silent = true })

-- Clear search with <esc>
keymap("n", "<esc>", "<cmd>noh<cr><esc>", { silent = true })

-- Save file
keymap("n", "<C-s>", "<cmd>w<cr><esc>", { silent = true })
keymap("i", "<C-s>", "<cmd>w<cr><esc>gi", { silent = true }) -- go back to insert mode with same position
keymap("v", "<C-s>", "<cmd>w<cr><esc>gv", { silent = true }) -- go back to visual mode with same selection

-- Move by visual line rather than physical line
-- Move correctly when text is wrapped and using {count}j/k
keymap("n", "j", function()
  if vim.v.count then
    return "j"
  else
    return "gj"
  end
end, { silent = true, expr = true })
keymap("n", "k", function()
  if vim.v.count then
    return "k"
  else
    return "gk"
  end
end, { silent = true, expr = true })

-- Stay in indent mode
keymap("v", "<", "<gv", { silent = true })
keymap("v", ">", ">gv", { silent = true })

-- Terminal-like experience for command line
keymap("c", "<C-a>", "<Home>", { silent = true })
keymap("c", "<C-e>", "<End>", { silent = true })

-- window
local status_ok, window = pcall(require, "vivek.window")
if status_ok then
  keymap("n", "<C-w>h", "<cmd> lua require('vivek.window').win_move('h')<cr>", { silent = true })
  keymap("n", "<C-w>j", "<cmd> lua require('vivek.window').win_move('j')<cr>", { silent = true })
  keymap("n", "<C-w>k", "<cmd> lua require('vivek.window').win_move('k')<cr>", { silent = true })
  keymap("n", "<C-w>l", "<cmd> lua require('vivek.window').win_move('l')<cr>", { silent = true })

  keymap(
    "n",
    "<C-left>",
    "<cmd> lua require('vivek.window').resize_win('left')<cr>",
    { silent = true }
  )
  keymap(
    "n",
    "<C-down>",
    "<cmd> lua require('vivek.window').resize_win('down')<cr>",
    { silent = true }
  )
  keymap("n", "<C-up>", "<cmd> lua require('vivek.window').resize_win('up')<cr>", { silent = true })
  keymap(
    "n",
    "<C-right>",
    "<cmd> lua require('vivek.window').resize_win('right')<cr>",
    { silent = true }
  )
end
