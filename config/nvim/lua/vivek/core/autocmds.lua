-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last_doc", { clear = true }),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- wrap and check for spell in writing filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text", "typst" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- create keymap to spell correct in writing filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("spell_correct", { clear = true }),
  pattern = { "gitcommit", "markdown", "text", "typst" },
  callback = function(event)
    vim.keymap.set("i", "z=", "<C-g>u<Esc>[S1z=`]a<C-g>u", { buffer = event.buf })
  end,
})

vim.api.nvim_create_user_command("TreesitterDebug", function()
  -- Open a new tab with current file
  vim.cmd("tabnew")
  vim.cmd("edit #")

  -- Open Treesitter Inspector
  vim.cmd("InspectTree")

  -- Open Query Editor
  vim.cmd("EditQuery")

  -- Adjust split sizes
  vim.cmd("wincmd =")
end, {})

-- Rename terminal buffer based on most recent command from zsh history
local function rename_terminal_buffer_to_current_command()
  local xdg_state = os.getenv("XDG_STATE_HOME") or vim.fn.expand("$HOME/.local/state")
  local history_file = xdg_state .. "/zsh/histfile"

  -- Read the last line from zsh history
  local handle = io.popen("tail -1 " .. history_file .. " 2>/dev/null")
  if not handle then
    return
  end

  local last_line = handle:read("*a")
  handle:close()

  if not last_line or last_line == "" then
    return
  end

  -- Parse command (format is usually: : timestamp:0;command)
  local command = last_line:match(";(.*)$")
  if not command then
    command = last_line
  end

  -- Trim whitespace
  command = command:gsub("^%s*(.-)%s*$", "%1")

  -- Check if it's a quit command
  if command == "q" or command == "quit" or command == "exit" then
    vim.cmd("quit")
    return
  end

  -- Rename buffer to include command
  local new_name = "term:" .. command
  vim.api.nvim_buf_set_name(0, new_name)

  -- Return to terminal insert mode
  vim.cmd("startinsert")
end

-- Set up terminal keymap to rename buffer on Enter
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("terminal_rename", { clear = true }),
  callback = function(event)
    vim.keymap.set("t", "<CR>", function()
      -- Send Enter to terminal
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
      -- Schedule the rename to happen after the command executes
      vim.defer_fn(function()
        rename_terminal_buffer_to_current_command()
      end, 100)
    end, { buffer = event.buf, silent = true })
  end,
})
