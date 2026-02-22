local function on_battery()
  local handle = io.popen("pmset -g batt 2>/dev/null")
  if not handle then
    return false
  end
  local output = handle:read("*a")
  handle:close()
  return output:find("Battery Power") ~= nil
end

return {
  "ggml-org/llama.vim",
  event = "InsertEnter",
  init = function()
    local enabled = not on_battery()
    vim.g.llama_config = {
      endpoint = "http://127.0.0.1:8012/infill",
      show_info = 0,
      auto_fim = enabled,
    }
  end,
  config = function()
    local Snacks = require("snacks")
    Snacks.toggle
      .new({
        name = "Llama Completions",
        get = function()
          return vim.g.llama_config and vim.g.llama_config.auto_fim
        end,
        set = function(state)
          local config = vim.g.llama_config or {}
          config.auto_fim = state
          vim.g.llama_config = config
        end,
      })
      :map("<leader>um")
  end,
}
