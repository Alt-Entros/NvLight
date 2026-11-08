-- Базы данных, как Database в GoLand: vim-dadbod + vim-dadbod-ui + автодополнение.
-- Боковая панель с подключениями → схемы → таблицы (колонки, индексы, ключи),
-- консоль запросов, результат в отдельном окне, автодополнение таблиц и колонок.
-- Работает через консольные клиенты: psql, mysql, sqlite3, sqlcmd, mongosh, redis-cli…
--
-- Подключения:
--   • <leader>Sa (или `A` в панели) — добавить, сохраняются в ~/.local/share/db_ui/connections.json;
--   • databases = { name = "url" } в lua/user.lua;
--   • переменные окружения / .env: DB_UI_<NAME>=url (например DB_UI_DEV=postgres://…).
local t = require("config.i18n").t

local sql_fts = { "sql", "mysql", "plsql" }

-- Привязать буфер к базе: в консолях из панели уже привязан,
-- для обычного .sql-файла DBUIFindBuffer спросит, к какой базе.
local function attach()
  if vim.b.dbui_db_key_name then return true end
  vim.cmd("DBUIFindBuffer")
  return vim.b.dbui_db_key_name ~= nil
end

-- what: "statement" — запрос под курсором (абзац между пустыми строками, как Ctrl+Enter в GoLand),
--       "selection" — выделение, "file" — весь буфер.
local function execute(what)
  return function()
    if what == "selection" then
      vim.cmd("normal! \27") -- выйти из visual, сохранив метки '< '>
    elseif what == "statement" then
      if vim.api.nvim_get_current_line():match("^%s*$") then
        vim.notify(t("Cursor is not on a query"), vim.log.levels.WARN)
        return
      end
      vim.cmd("normal! vip\27")
    end
    if not attach() then return end
    local keys = what == "file" and "<Plug>(DBUI_ExecuteQuery)" or "gv<Plug>(DBUI_ExecuteQuery)"
    vim.api.nvim_feedkeys(vim.keycode(keys), "m", false)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = sql_fts,
  group = vim.api.nvim_create_augroup("user_dadbod", { clear = true }),
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "<C-CR>", execute("statement"), t("Run query under cursor"))
    map("x", "<C-CR>", execute("selection"), t("Run selection"))
    map("n", "<leader>Se", execute("statement"), t("Run query under cursor"))
    map("x", "<leader>Se", execute("selection"), t("Run selection"))
    map("n", "<leader>SE", execute("file"), t("Run whole file"))
    map("n", "<leader>Sb", "<cmd>DBUIFindBuffer<cr>", t("Attach file to database"))
    map("n", "<leader>Ss", "<Plug>(DBUI_SaveQuery)", t("Save query"))
    map("n", "<leader>Sp", "<Plug>(DBUI_EditBindParameters)", t("Edit bind parameters"))
  end,
})

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = sql_fts, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer", "DB" },
    keys = {
      { "<leader>SS", "<cmd>DBUIToggle<cr>", desc = t("Database panel") },
      { "<leader>Sa", "<cmd>DBUIAddConnection<cr>", desc = t("Add connection") },
      { "<leader>Sr", "<cmd>DBUIRenameBuffer<cr>", desc = t("Rename query") },
      { "<leader>Si", "<cmd>DBUILastQueryInfo<cr>", desc = t("Last query info") },
    },
    init = function()
      local dbs = require("config.settings").databases
      if dbs and next(dbs) then vim.g.dbs = dbs end

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_use_nvim_notify = 1
      -- Не выполнять запрос при сохранении: здесь <C-s> и формат при сохранении,
      -- случайный UPDATE/DELETE не нужен. Запуск — <C-Enter> / <leader>Se.
      vim.g.db_ui_execute_on_save = 0
      -- Открыть таблицу (Enter на таблице → List) — сразу показать данные, как в GoLand
      vim.g.db_ui_auto_execute_table_helpers = 1
      -- Свои клавиши в SQL-буферах (<leader>S…, <C-Enter>) вместо встроенных <leader>S/W/E
      vim.g.db_ui_disable_mappings_sql = 1
    end,
  },

  -- Автодополнение таблиц/колонок/схем в blink.cmp
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources.providers.dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink", score_offset = 50 }
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      for _, ft in ipairs(sql_fts) do
        opts.sources.per_filetype[ft] = { "dadbod", "snippets", "buffer" }
      end
    end,
  },
}
