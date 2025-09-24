return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      local exe = vim.fn.executable

      -- map linter name -> actual executable (when they differ)
      local exe_of = {
        golangcilint = 'golangci-lint',
        ['markdownlint-cli2'] = 'markdownlint-cli2',
      }

      -- helper: pick only linters that are installed
      local function available(names)
        local out = {}
        for _, name in ipairs(names) do
          local bin = exe_of[name] or name
          if exe(bin) == 1 then table.insert(out, name) end
        end
        return (#out > 0) and out or nil
      end

      -- Choose the linters you want per filetype (left-to-right preference)
      lint.linters_by_ft = {
        markdown   = available({ 'markdownlint', 'markdownlint-cli2' }),
        lua        = available({ 'luacheck' }),
        json       = available({ 'jsonlint' }),
        yaml       = available({ 'yamllint' }),
        dockerfile = available({ 'hadolint' }),
        sh         = available({ 'shellcheck' }),  -- works for sh/bash/zsh buffers
        bash       = available({ 'shellcheck' }),
        zsh        = available({ 'shellcheck' }),
        python     = available({ 'ruff' }),        -- super fast Python linter
        go         = available({ 'golangcilint' }),-- requires golangci-lint
        -- add more here as you like
      }

      -- Only run if there is at least one installed linter for this buffer's ft
      local function safe_try_lint()
        if not vim.bo.modifiable then return end
        local names = lint.linters_by_ft[vim.bo.filetype]
        if not names then return end
        -- double-check availability in case PATH changed after startup
        for i, name in ipairs(names) do
          local bin = exe_of[name] or name
          if exe(bin) == 1 then
            lint.try_lint()
            return
          else
            -- if a configured linter disappeared, drop it for this session
            names[i] = nil
          end
        end
      end

      local grp = vim.api.nvim_create_augroup('lint-anyft', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = grp,
        callback = safe_try_lint,
      })

      -- Optional: manual command
      vim.api.nvim_create_user_command('Lint', function() safe_try_lint() end, {})
    end,
  },
}

-- return {

--   { -- Linting
--     'mfussenegger/nvim-lint',
--     event = { 'BufReadPre', 'BufNewFile' },
--     config = function()
--       local lint = require 'lint'
--       lint.linters_by_ft = {
--         markdown = { 'markdownlint' },
--       }

--       -- To allow other plugins to add linters to require('lint').linters_by_ft,
--       -- instead set linters_by_ft like this:
--       -- lint.linters_by_ft = lint.linters_by_ft or {}
--       -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
--       --
--       -- However, note that this will enable a set of default linters,
--       -- which will cause errors unless these tools are available:
--       -- {
--       --   clojure = { "clj-kondo" },
--       --   dockerfile = { "hadolint" },
--       --   inko = { "inko" },
--       --   janet = { "janet" },
--       --   json = { "jsonlint" },
--       --   markdown = { "vale" },
--       --   rst = { "vale" },
--       --   ruby = { "ruby" },
--       --   terraform = { "tflint" },
--       --   text = { "vale" }
--       -- }
--       --
--       -- You can disable the default linters by setting their filetypes to nil:
--       -- lint.linters_by_ft['clojure'] = nil
--       -- lint.linters_by_ft['dockerfile'] = nil
--       -- lint.linters_by_ft['inko'] = nil
--       -- lint.linters_by_ft['janet'] = nil
--       -- lint.linters_by_ft['json'] = nil
--       -- lint.linters_by_ft['markdown'] = nil
--       -- lint.linters_by_ft['rst'] = nil
--       -- lint.linters_by_ft['ruby'] = nil
--       -- lint.linters_by_ft['terraform'] = nil
--       -- lint.linters_by_ft['text'] = nil

--       -- Create autocommand which carries out the actual linting
--       -- on the specified events.
--       local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
--       vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
--         group = lint_augroup,
--         callback = function()
--           -- Only run the linter in buffers that you can modify in order to
--           -- avoid superfluous noise, notably within the handy LSP pop-ups that
--           -- describe the hovered symbol using Markdown.
--           if vim.bo.modifiable then
--             lint.try_lint()
--           end
--         end,
--       })
--     end,
--   },
-- }
