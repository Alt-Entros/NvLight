-- Подсветка синтаксиса. Ветка main nvim-treesitter (новый API):
-- парсеры ставятся через install(), подсветка включается через vim.treesitter.start().
-- Для сборки парсеров нужен tree-sitter CLI (ставится через Mason) и компилятор C.
local t = require("config.i18n").t
local parsers = {
  "c", "cpp", "c_sharp", "python", "lua", "luadoc", "vim", "vimdoc", "query",
  "bash", "dockerfile", "yaml", "json", "toml", "nginx", "caddy", "ini", "xml",
  "make", "cmake", "markdown", "markdown_inline", "regex", "diff", "gitcommit",
  "gitignore", "html", "css", "javascript", "typescript", "tsx", "vue", "sql",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")

      -- Ставим только недостающие парсеры (в фоне).
      -- Возвращает false, если нужен tree-sitter CLI, а его ещё нет.
      local function install_missing()
        local installed = ts.get_installed()
        local missing = vim.tbl_filter(function(p) return not vim.tbl_contains(installed, p) end, parsers)
        if #missing == 0 then return true end
        if vim.fn.executable("tree-sitter") ~= 1 then return false end
        ts.install(missing, { summary = true })
        return true
      end

      if not install_missing() then
        -- CLI ставит Mason в фоне — дождёмся, пока он закончит, и попробуем снова
        vim.api.nvim_create_autocmd("User", {
          pattern = "MasonToolsUpdateCompleted",
          once = true,
          callback = function()
            vim.schedule(function()
              if not install_missing() then
                vim.notify(
                  t("tree-sitter CLI not found — check :Mason (tree-sitter-cli) or install it: brew install tree-sitter-cli"),
                  vim.log.levels.WARN
                )
              end
            end)
          end,
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          -- подсветка + свёртки по синтаксису, если парсер есть
          if pcall(vim.treesitter.start, args.buf) then
            vim.wo[0][0].foldmethod = "expr"
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },
}
