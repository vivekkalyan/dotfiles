local M = {}

function M.win_move(key)
  local curwin = vim.api.nvim_get_current_win()
  vim.api.nvim_command("wincmd " .. key)
  if curwin == vim.api.nvim_get_current_win() then
    if string.match(key, "[jk]") then
      vim.api.nvim_command("wincmd s")
    else
      vim.api.nvim_command("wincmd v")
    end
    vim.api.nvim_command("wincmd " .. key)
  end
end

function M.resize_win(key)
  vim.api.nvim_command("wincmd " .. M.get_direction(key))
end

function M.get_direction(key)
  local ei = M.get_edge_info()
  if ei.right and key == "left" then
    return ">"
  elseif ei.right and key == "right" then
    return "<"
  elseif ei.up and key == "up" then
    return "-"
  elseif ei.up and key == "down" then
    return "+"
  elseif key == "left" then
    return "<"
  elseif key == "right" then
    return ">"
  elseif key == "up" then
    return "+"
  elseif key == "down" then
    return "-"
  end
end

function M.get_edge_info()
  local check_directions = { "up", "right" }
  local result = {}
  for _, direction in ipairs(check_directions) do
    result[direction] = M.can_move_cursor_from_current_window(direction)
  end
  return result
end

function M.can_move_cursor_from_current_window(direction)
  local map_directions = { up = "k", right = "l" }
  if map_directions[direction] then
    direction = map_directions[direction]
  elseif vim.tbl_contains(vim.tbl_values(map_directions), direction) then
    direction = direction
  end
  local from = vim.api.nvim_get_current_win()
  vim.api.nvim_command("wincmd " .. direction)
  local to = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(from)
  return from == to
end

return M
