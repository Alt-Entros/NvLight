-- Форматирование (conform) и дополнительные линтеры (nvim-lint).
-- Форматирование при сохранении включено; <leader>uf — выключить/включить.
local t = require("config.i18n").t
vim.g.format_on_save = require("config.settings").format_on_save

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>lf", function() require("conform").format({ async = true }) end, mode = { "n", "v" }, desc = t("Format") },
      { "<leader>uf", function()
          vim.g.format_on_save = not vim.g.format_on_save
          vim.notify(t("Format on save") .. ": " .. t(vim.g.format_on_save and "on" or "off"))
        end, desc = t("Toggle format on save") },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        cs = { "csharpier" },
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        toml = { "taplo" },
        caddy = { "caddy_fmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        ["yaml.docker-compose"] = { "prettier" },
        ["yaml.ansible"] = { "prettier" },
        markdown = { "prettier" },
      },
      formatters = {
        -- Caddyfile форматирует сам caddy (если установлен: brew install caddy)
        caddy_fmt = { command = "caddy", args = { "fmt", "-" }, stdin = true },
      },
      default_format_opts = { lsp_format = "fallback" }, -- нет форматтера — форматирует LSP
      format_on_save = function()
        if not vim.g.format_on_save then return end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
    init = function()
      -- gq тоже форматирует через conform
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      -- Остальное (clang-tidy, ruff, shellcheck, ansible-lint) уже делают LSP
      lint.linters_by_ft = {
        dockerfile = { "hadolint" },
      }
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
        callback = function()
          -- запускать только если бинарник установлен — без ошибок до установки Mason
          local names = lint._resolve_linter_by_ft(vim.bo.filetype)
          names = vim.tbl_filter(function(name)
            local linter = lint.linters[name]
            local cmd = type(linter) == "table" and linter.cmd or name
            return type(cmd) ~= "string" or vim.fn.executable(cmd) == 1
          end, names)
          if #names > 0 then lint.try_lint(names) end
        end,
      })
    end,
  },
}
