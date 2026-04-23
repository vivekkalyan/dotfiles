local api = vim.api
local M = {}

local augroup = api.nvim_create_augroup("commit_ai", { clear = true })
local endpoint = "http://127.0.0.1:8012/v1/chat/completions"
local model = "qwen3.6-27b"

local function trim(text)
  return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function truncate(text, max_chars)
  if #text <= max_chars then
    return text
  end
  return text:sub(1, max_chars) .. "\n...[truncated]"
end

local function comment_prefix(buf)
  local commentstring = vim.bo[buf].commentstring or "# %s"
  local prefix = commentstring:match("^(.*)%%s") or "#"
  return vim.pesc(trim(prefix))
end

local function has_message(buf)
  if not api.nvim_buf_is_valid(buf) then
    return false
  end

  local comment = "^" .. comment_prefix(buf)
  for _, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local stripped = trim(line)
    if stripped ~= "" and not stripped:match(comment) then
      return true
    end
  end

  return false
end

local function insert_subject(buf, subject)
  if not api.nvim_buf_is_valid(buf) or has_message(buf) then
    return
  end

  local comment = "^" .. comment_prefix(buf)
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local replace_to = #lines

  for index, line in ipairs(lines) do
    if trim(line):match(comment) then
      replace_to = index - 1
      break
    end
  end

  api.nvim_buf_set_lines(buf, 0, replace_to, false, { subject, "" })
end

local function run(command, opts, callback)
  vim.system(command, vim.tbl_extend("keep", opts or {}, { text = true }), function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

local function normalize_subject(raw)
  local subject = trim(raw)
  subject = subject:gsub("^```.-\n", "")
  subject = subject:gsub("\n```$", "")
  subject = subject:gsub("^['\"](.-)['\"]$", "%1")
  subject = subject:gsub("^commit message:%s*", "")
  subject = subject:gsub("^subject:%s*", "")
  subject = subject:gsub("^[-*]%s*", "")
  subject = trim((subject:match("[^\r\n]+")) or "")
  subject = subject:gsub("%.$", "")
  return trim(subject)
end

local function request_subject(buf, root, context)
  local repo_name = vim.fs.basename(root)
  local payload = vim.json.encode({
    model = model,
    temperature = 0.2,
    top_p = 0.95,
    max_tokens = 48,
    messages = {
      {
        role = "system",
        content = table.concat({
          "You write git commit subjects.",
          "Return exactly one subject line and nothing else.",
          "Prefer the repository's existing style if it is clear from recent subjects.",
          "Otherwise use a concise conventional commit style like feat: or fix:.",
          "Keep it under 72 characters.",
          "Do not use quotes, bullets, or a trailing period.",
        }, " "),
      },
      {
        role = "user",
        content = table.concat({
          "Repository: " .. repo_name,
          "",
          "Recent commit subjects:",
          context.subjects ~= "" and context.subjects or "(none)",
          "",
          "Staged diff summary:",
          context.stat ~= "" and context.stat or "(none)",
          "",
          "Staged diff excerpt:",
          context.diff ~= "" and context.diff or "(none)",
          "",
          "Write only the commit subject.",
        }, "\n"),
      },
    },
    chat_template_kwargs = {
      enable_thinking = false,
    },
  })

  run({
    "curl",
    "-sS",
    "--max-time",
    "20",
    "-H",
    "Content-Type: application/json",
    "-d",
    payload,
    endpoint,
  }, {}, function(result)
    if result.code ~= 0 or not api.nvim_buf_is_valid(buf) then
      return
    end

    local ok, response = pcall(vim.json.decode, result.stdout)
    if not ok or type(response) ~= "table" then
      return
    end

    local choice = response.choices and response.choices[1]
    local message = choice and choice.message or {}
    local subject = normalize_subject(message.content or "")
    if subject == "" then
      return
    end

    vim.b[buf].commit_ai_last_subject = subject
    insert_subject(buf, subject)
  end)
end

local function gather_context(buf, root)
  run({ "git", "log", "-6", "--pretty=%s" }, { cwd = root }, function(log_result)
    local subjects = trim(log_result.stdout or "")

    run({ "git", "diff", "--cached", "--stat", "--summary", "--no-color" }, { cwd = root }, function(stat_result)
      local stat = trim(stat_result.stdout or "")

      run({ "git", "diff", "--cached", "--unified=0", "--no-color", "--no-ext-diff" }, { cwd = root }, function(diff_result)
        local diff = trim(diff_result.stdout or "")
        if diff == "" then
          return
        end

        request_subject(buf, root, {
          subjects = truncate(subjects, 600),
          stat = truncate(stat, 4000),
          diff = truncate(diff, 12000),
        })
      end)
    end)
  end)
end

function M.suggest(buf)
  if not api.nvim_buf_is_valid(buf) or vim.b[buf].commit_ai_requested or has_message(buf) then
    return
  end

  local name = api.nvim_buf_get_name(buf)
  if not name:match("COMMIT_EDITMSG$") then
    return
  end

  vim.b[buf].commit_ai_requested = true
  gather_context(buf, vim.fn.fnamemodify(name, ":p:h:h"))
end

api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "gitcommit",
  callback = function(event)
    if not vim.b[event.buf].commit_ai_command_created then
      api.nvim_buf_create_user_command(event.buf, "CommitAISuggest", function()
        vim.b[event.buf].commit_ai_last_subject = nil
        vim.b[event.buf].commit_ai_requested = nil
        M.suggest(event.buf)
      end, { desc = "Suggest a commit subject from staged changes" })
      vim.b[event.buf].commit_ai_command_created = true
    end

    vim.schedule(function()
      M.suggest(event.buf)
    end)
  end,
})

return M
