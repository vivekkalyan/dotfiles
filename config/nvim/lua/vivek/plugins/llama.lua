return {
  "ggml-org/llama.vim",
  event = "InsertEnter",
  init = function()
    vim.g.llama_config = {
      endpoint = "http://127.0.0.1:8012/infill",
      show_info = 0,
      auto_fim = true,
    }
  end,
}
