local M = {}

function M.ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank =
      vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- register all text objects with which-key
---@param opts table
function M.ai_whichkey(opts)
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = 'string "' },
    { "'", desc = "string '" },
    { "(", desc = "parentheses" },
    { ")", desc = "parentheses (whitespace)" },
    { "<", desc = "angle brackets" },
    { ">", desc = "angle brackets (whitespace)" },
    { "?", desc = "user prompt" },
    { "[", desc = "square brackets" },
    { "]", desc = "square brackets (whitespace)" },
    { "_", desc = "underscore" },
    { "`", desc = "string `" },
    { "a", desc = "argument" },
    { "b", desc = "brackets )]} " },
    { "q", desc = "quotes `'\"" },
    { "{", desc = "curly braces" },
    { "}", desc = "curly braces (whitespace)" },
  }

  -- Objects that don't show inner/outer in description
  local same_desc_objects = {
    { "e", desc = "word part" },
    { "t", desc = "tag" },
    { "U", desc = "function call (without .)" },
  }

  -- Objects only for around (not inside)
  local around_only_objects = {
    { "g", desc = "entire buffer" },
  }

  ---@type wk.Spec[]
  local ret = { mode = { "o", "x" } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend("force", {}, {
    around = "a",
    inside = "i",
  }, opts.mappings or {})
  -- Remove goto mappings as they're not needed for text objects
  mappings.goto_left = nil
  mappings.goto_right = nil
  -- Build the which-key specs
  for name, prefix in pairs(mappings) do
    local type_name = name:gsub("^around_", ""):gsub("^inside_", "")
    local is_inside = prefix:sub(1, 1) == "i"
    local prefix_type = is_inside and "inner" or "outer"

    -- Add group for the prefix
    ret[#ret + 1] = { prefix, group = type_name }

    -- Add standard objects with inner/outer prefix
    for _, obj in ipairs(objects) do
      ret[#ret + 1] = {
        prefix .. obj[1],
        desc = prefix_type .. " " .. obj.desc,
      }
    end

    -- Add objects with same description for both
    for _, obj in ipairs(same_desc_objects) do
      ret[#ret + 1] = {
        prefix .. obj[1],
        desc = obj.desc,
      }
    end

    -- Add around-only objects (skip for inside)
    if not is_inside then
      for _, obj in ipairs(around_only_objects) do
        ret[#ret + 1] = {
          prefix .. obj[1],
          desc = obj.desc,
        }
      end
    end
  end
  require("which-key").add(ret, { notify = false })
end
return M
