-- Общие клавиши. Клавиши плагинов — в lua/plugins/*.lua (секция keys),
-- клавиши LSP — в lua/plugins/lsp.lua (LspAttach).
-- Посмотреть всё: <leader>fk (поиск по клавишам) или просто нажать <leader> и подождать.

local map = vim.keymap.set

-- Привычное из NvChad
map("n", ";", ":", { desc = "Командный режим" })
map("i", "jk", "<Esc>", { desc = "Выйти в normal" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Сохранить" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Убрать подсветку поиска" })
map("n", "<C-c>", "<cmd>%y+<cr>", { desc = "Скопировать весь файл" })

-- Комментарии (встроенный gc, как <leader>/ в NvChad)
map("n", "<leader>/", "gcc", { remap = true, desc = "Комментарий строки" })
map("v", "<leader>/", "gc", { remap = true, desc = "Комментарий выделения" })

-- Окна
map("n", "<C-h>", "<C-w>h", { desc = "Окно слева" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно снизу" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно сверху" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно справа" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Выше" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Ниже" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Уже" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Шире" })
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Сплит вертикально" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Сплит горизонтально" })

-- Перемещение строк (Alt+j/k) и отступы без потери выделения
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Строку вниз" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Строку вверх" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Выделение вниз" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Выделение вверх" })
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Буфер обмена: вставка поверх выделения без потери скопированного,
-- и удаление в «чёрную дыру», чтобы не затирать системный буфер
map("x", "<leader>p", [["_dP]], { desc = "Вставить, не затирая буфер" })
map({ "n", "v" }, "<leader>D", [["_d]], { desc = "Удалить без копирования" })
map("n", "x", [["_x]], { desc = "Удалить символ без копирования" })

-- Терминал: выход из режима ввода
map("t", "<C-x>", [[<C-\><C-n>]], { desc = "Выйти из режима терминала" })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Выйти из режима терминала" })

-- Диагностика
map("n", "gl", vim.diagnostic.open_float, { desc = "Ошибка под курсором" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Ошибка под курсором" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Ошибки в loclist" })
-- ]d / [d — следующая/предыдущая ошибка (встроено в nvim)

-- Переключатели интерфейса
map("n", "<leader>ut", function() require("config.theme").toggle_transparency() end,
  { desc = "Прозрачность вкл/выкл" })
map("n", "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, { desc = "Перенос строк" })
map("n", "<leader>un", function() vim.wo.relativenumber = not vim.wo.relativenumber end,
  { desc = "Относительные номера" })
map("n", "<leader>ul", function()
  local cfg = vim.diagnostic.config() or {}
  local on = not cfg.virtual_lines
  vim.diagnostic.config({ virtual_lines = on and { current_line = true } or false, virtual_text = not on })
end, { desc = "Ошибки: строкой под кодом / справа" })
map("n", "<leader>ud", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Диагностика вкл/выкл" })

-- Темы (как в NvChad)
map("n", "<leader>th", function() require("config.theme").pick() end, { desc = "Выбрать тему" })

-- Lazy / Mason
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy (плагины)" })
map("n", "<leader>M", "<cmd>Mason<cr>", { desc = "Mason (LSP/форматтеры)" })
