local options = {
  -- General
  fileencoding = "utf-8",                   -- the encoding written to a file
  scrolloff = 3,                            -- minimum lines to keep in view around cursor
  sidescrolloff = 3,                        -- minimum lines to keep in view around cursor
  pumheight = 10,                          -- pop up menu height
  laststatus = 2,                           -- always show status bar
  clipboard = "unnamed",                    -- use system clipboard

  -- Formatting
  tabstop = 2,                              -- nunber of visual spaces per tab
  softtabstop = 2,                          -- number of spaces in tab when editing
  expandtab = true,                         -- tabs are spaces
  shiftwidth = 2,                           -- number of spaces in (auto)indent
  autoindent = true,                        -- follow indentendation of previous line
  smartindent = true,                       -- smart autoindenting when starting a new line
  shiftround = true,                        -- always indent by multiple of shiftwidth
  joinspaces = false,                       -- don't autoinsert two spaces after '.', '?', '!' for join command

  -- Wrap
  wrap = true,                              -- wrap text
  textwidth = 120,                          -- ... at 120 characters
  breakindent = true,                       -- indent wrapped lines to match start

  -- Folding
  foldlevelstart = 1,                       -- folds by default
  foldmethod = "indent",                    -- fold based on indent level

  -- UI Config
  relativenumber = true,                    -- set relative numbered lines
  number = true,                            -- set numbered lines
  showcmd = true,                           -- show command in bottom bar
  showmode = true,                          -- show mode in bottom bar
  cursorline = true,                        -- highlight the current line
  lazyredraw = true,                        -- redraw only when we need to.
  showmatch = true,                         -- highlight matching [{()}]
  list = true,                              -- show whitespace
  listchars = "tab:▷┅,trail:•",             -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7)
                                            -- BOX DRAWINGS HEAVY TRIPLE DASH HORIZONTAL (U+2505, UTF-8: E2 94 85)
                                            -- BULLET (U+2022, UTF-8: E2 80 A2)

  -- Windows
  splitbelow = true,                        -- open horizontal split below current window
  splitright = true,                        -- open vertical split to the right of current window
  switchbuf = "usetab",                     -- try to reuse windows/tabs when switching buffers
  hidden = true,                            -- allow switching modified buffers
  fillchars = "vert:┃",                     -- solid line to seperate windows

  -- Search
  ignorecase = true,                        -- Ignore case when typing
  smartcase = true,                         -- ... unless we type a capital
  incsearch = true,                         -- Incremental searching
  hlsearch = true,                          -- Highlight matches when searching

  backup = false,                          -- creates a backup file
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  swapfile = false,                        -- creates a swapfile
  timeout = true,                          -- enable timeout for waiting for a mapped sequence to complete
  timeoutlen = 1000,                        -- time to wait for a mapped sequence to complete
  undofile = true,                         -- enable persistent undo
  updatetime = 300,                        -- faster completion (4000ms default)
  writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
}


for k, v in pairs(options) do
  vim.opt[k] = v
end

-- statusline
vim.cmd [[set statusline=[%n]\ %<%f\ %m%r%#Pmenu#%=%-14.(%*%l,%c%V%)]]
vim.cmd [[set nrformats+=bin]]              -- allow C-A, C-X for binary
vim.cmd [[set iskeyword+=-]]                -- make word definition include -
vim.cmd [[set formatoptions+=n]]            -- smart auto-indenting inside numbered lists
