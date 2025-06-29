return {
  "philosofonusus/ecolog.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>eg", "<cmd>EcologGoto<cr>", desc = "Go to env file" },
    { "<leader>ep", "<cmd>EcologPeek<cr>", desc = "Ecolog peek variable" },
    { "<leader>es", "<cmd>EcologSelectWithPath<cr>", desc = "Switch env file" },
    -- Quick switch to current package env with selection menu
    {
      "<leader>el",
      function()
        local current = vim.fn.expand("%:p:h")

        -- Check for both package.json and pyproject.toml
        local markers = { "package.json", "pyproject.toml" }
        local found_root = nil

        for _, marker in ipairs(markers) do
          local marker_file = vim.fn.findfile(marker, current .. ";")
          if marker_file ~= "" then
            found_root = vim.fn.fnamemodify(marker_file, ":h")
            break
          end
        end

        if found_root then
          -- Look for .env and .env.* files
          local env_files = vim.fn.glob(found_root .. "/.env*", false, true)

          -- Filter and create relative paths
          local valid_env_files = {}
          for _, file in ipairs(env_files) do
            local basename = vim.fn.fnamemodify(file, ":t")
            -- Match .env or .env.something (but not .envrc or .env.example)
            if
              basename == ".env"
              or (basename:match("^%.env%.") and not basename:match("%.example$"))
            then
              table.insert(valid_env_files, {
                path = file,
                name = basename,
                relative = vim.fn.fnamemodify(file, ":."),
              })
            end
          end

          if #valid_env_files == 0 then
            vim.notify("No .env files found in " .. found_root, vim.log.levels.WARN)
          elseif #valid_env_files == 1 then
            vim.cmd("EcologSelect " .. valid_env_files[1].path)
          else
            -- Show selection menu
            vim.ui.select(valid_env_files, {
              prompt = "Select environment file:",
              format_item = function(item)
                return item.relative
              end,
            }, function(choice)
              if choice then
                vim.cmd("EcologSelect " .. choice.path)
              end
            end)
          end
        else
          vim.notify("No package root found (package.json or pyproject.toml)", vim.log.levels.WARN)
        end
      end,
      desc = "Local package env",
    },
  },
  config = function(_, opts)
    require("ecolog").setup(opts)

    -- Create a custom command that shows paths
    vim.api.nvim_create_user_command("EcologSelectWithPath", function()
      -- Get all env files based on the patterns
      local env_files = {}
      local cwd = vim.fn.getcwd()

      -- Search patterns from your config
      local patterns = { ".env", ".env.*", "*.env*", "**/.env" }

      for _, pattern in ipairs(patterns) do
        local files = vim.fn.glob(cwd .. "/" .. pattern, false, true)
        for _, file in ipairs(files) do
          local basename = vim.fn.fnamemodify(file, ":t")
          -- Filter out example files and other non-env files
          if basename:match("^%.env") and not basename:match("%.example$") then
            table.insert(env_files, {
              path = file,
              name = basename,
              relative = vim.fn.fnamemodify(file, ":."),
              dir = vim.fn.fnamemodify(file, ":h:t"), -- parent directory name
            })
          end
        end
      end

      -- Remove duplicates
      local seen = {}
      local unique_files = {}
      for _, file in ipairs(env_files) do
        if not seen[file.path] then
          seen[file.path] = true
          table.insert(unique_files, file)
        end
      end

      if #unique_files == 0 then
        vim.notify("No .env files found", vim.log.levels.WARN)
      elseif #unique_files == 1 then
        vim.cmd("EcologSelect " .. unique_files[1].path)
      else
        -- Sort by relative path for better organization
        table.sort(unique_files, function(a, b)
          return a.relative < b.relative
        end)

        -- Show selection menu with paths
        vim.ui.select(unique_files, {
          prompt = "Select environment file:",
          format_item = function(item)
            -- Show relative path and highlight the filename
            return string.format("%-40s (%s)", item.relative, item.name)
          end,
        }, function(choice)
          if choice then
            vim.cmd("EcologSelect " .. choice.path)
          end
        end)
      end
    end, {})
  end,
  -- Lazy loading is done internally
  opts = {
    integrations = {
      blink_cmp = true,
    },
    -- Enables shelter mode for sensitive values
    shelter = {
      configuration = {
        partial_mode = false, -- false by default, disables partial mode, for more control check out shelter partial mode
        mask_char = "*", -- Character used for masking
      },
      modules = {
        cmp = true, -- Mask values in completion
        peek = false, -- Mask values in peek view
        files = true, -- Mask values in files
        telescope = true, -- Mask values in telescope
        telescope_previewer = true, -- Mask values in telescope preview buffers
        fzf = false, -- Mask values in fzf picker
        fzf_previewer = false, -- Mask values in fzf preview buffers
      },
    },
    -- true by default, enables built-in types (database_url, url, etc.)
    types = true,
    path = vim.fn.getcwd(), -- Path to search for .env files
    env_file_patterns = { ".env", ".env.*", "*.env*", "**/.env" },
    preferred_environment = "development", -- Optional: prioritize specific env files
    -- Controls how environment variables are extracted from code and how cmp works
    provider_patterns = true, -- true by default, when false will not check provider patterns
  },
}
