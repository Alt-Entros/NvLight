-- Общие клавиши. Клавиши плагинов — в lua/plugins/*.lua (секция keys),
-- клавиши LSP — в lua/plugins/lsp.lua (LspAttach).
-- Посмотреть всё: <leader>fk (поиск по клавишам) или просто нажать <leader> и подождать.
local t = require("config.i18n").t

local map = vim.keymap.set

-- Привычное из NvChad
map("n", ";", ":", { desc = t("Command mode") })
map("i", "jk", "<Esc>", { desc = t("Exit to normal mode") })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = t("Save file") })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = t("Clear search highlight") })
map("n", "<C-c>", "<cmd>%y+<cr>", { desc = t("Copy whole file") })

-- Комментарии (встроенный gc, как <leader>/ в NvChad)
map("n", "<leader>/", "gcc", { remap = true, desc = t("Toggle comment (line)") })
map("v", "<leader>/", "gc", { remap = true, desc = t("Toggle comment (selection)") })

-- Окна
map("n", "<C-h>", "<C-w>h", { desc = t("Window left") })
map("n", "<C-j>", "<C-w>j", { desc = t("Window below") })
map("n", "<C-k>", "<C-w>k", { desc = t("Window above") })
map("n", "<C-l>", "<C-w>l", { desc = t("Window right") })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = t("Increase height") })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = t("Decrease height") })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = t("Decrease width") })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = t("Increase width") })
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = t("Vertical split") })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = t("Horizontal split") })

-- Перемещение строк (Alt+j/k) и отступы без потери выделения
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = t("Move line down") })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = t("Move line up") })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = t("Move selection down") })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = t("Move selection up") })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Буфер обмена: вставка поверх выделения без потери скопированного,
-- и удаление в «чёрную дыру», чтобы не затирать системный буфер
map("x", "<leader>p", [["_dP]], { desc = t("Paste without overwriting register") })
map({ "n", "v" }, "<leader>D", [["_d]], { desc = t("Delete without copying") })
map("n", "x", [["_x]], { desc = t("Delete char without copying") })

-- Терминал: выход из режима ввода
map("t", "<C-x>", [[<C-\><C-n>]], { desc = t("Exit terminal mode") })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = t("Exit terminal mode") })

-- Диагностика
map("n", "gl", vim.diagnostic.open_float, { desc = t("Line diagnostics") })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = t("Line diagnostics") })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = t("Diagnostics to loclist") })
-- ]d / [d — следующая/предыдущая ошибка (встроено в nvim)

-- Переключатели интерфейса
map("n", "<leader>ut", function() require("config.theme").toggle_transparency() end,
  { desc = t("Toggle transparency") })
map("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = t("Toggle line wrap") })
map("n", "<leader>un", function() vim.wo.relativenumber = not vim.wo.relativenumber end,
  { desc = t("Toggle relative numbers") })
map("n", "<leader>ul", function()
  local cfg = vim.diagnostic.config() or {}
  local on = not cfg.virtual_lines
  vim.diagnostic.config({ virtual_lines = on and { current_line = true } or false, virtual_text = not on })
end, { desc = t("Toggle diagnostics: virtual lines / text") })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = t("Toggle diagnostics") })

-- Темы (как в NvChad)
map("n", "<leader>th", function() require("config.theme").pick() end, { desc = t("Pick theme") })

-- Lazy / Mason
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = t("Lazy (plugins)") })
map("n", "<leader>M", "<cmd>Mason<cr>", { desc = t("Mason (LSP/formatters)") })
