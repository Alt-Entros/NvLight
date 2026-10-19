-- Терминал: toggleterm.
-- Три независимых терминала (плавающий, снизу, сбоку) + lazygit + запуск текущего файла.
-- Alt-клавиши в kitty на macOS работают только с `macos_option_as_alt yes` в kitty.conf,
-- поэтому всё продублировано на <leader>t.

local terms = {}

local function term(key, opts)
  if not terms[key] then
    local Terminal = require("toggleterm.terminal").Terminal
    terms[key] = Terminal:new(vim.tbl_extend("force", { hidden = true }, opts))
  end
  return terms[key]
end

local function toggle(key, opts)
  return function() term(key, opts):toggle() end
end

local float = { direction = "float", count = 101 }
local bottom = { direction = "horizontal", count = 102 }
local side = { direction = "vertical", count = 103 }

-- ── Запуск текущего файла ─────────────────────────────────────────
-- Работает и на macOS/Linux (zsh/bash), и на Windows (PowerShell).
local is_win = vim.fn.has("win32") == 1

local function first_exe(list)
  for _, c in ipairs(list) do
    if vim.fn.executable(c) == 1 then return c end
  end
  return list[1]
end

-- «собрать, и если успешно — запустить»
local function and_then(a, b)
  if is_win then return a .. "; if ($?) { " .. b .. " }" end
  return a .. " && " .. b
end

local function exec(path) return is_win and ("& " .. path) or path end

local runners = {
  c = function(f, out)
    return and_then(("%s -Wall -Wextra -g %s -o %s"):format(first_exe({ "gcc", "clang" }), f, out), exec(out))
  end,
  cpp = function(f, out)
    return and_then(("%s -std=c++20 -Wall -Wextra -g %s -o %s"):format(first_exe({ "g++", "clang++" }), f, out), exec(out))
  end,
  cs = function() return "dotnet run" end,
  -- на Windows python3 часто ведёт в Microsoft Store, поэтому там python
  python = function(f) return (is_win and "python " or "python3 ") .. f end,
  lua = function(f) return "lua " .. f end,
  sh = function(f) return "bash " .. f end,
  javascript = function(f) return "node " .. f end,
  typescript = function(f) return "npx tsx " .. f end,
  go = function() return "go run ." end,
}

local function run_file()
  vim.cmd("silent! write")
  local ft = vim.bo.filetype
  local runner = runners[ft]
  if not runner then
    vim.notify("Не знаю, как запустить " .. ft .. " — добавь в runners (lua/plugins/terminal.lua)", vim.log.levels.WARN)
    return
  end
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  local bin_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "run")
  vim.fn.mkdir(bin_dir, "p")
  local out = vim.fn.shellescape(vim.fs.joinpath(bin_dir, vim.fn.expand("%:t:r") .. (is_win and ".exe" or "")))
  local t = term("bottom", bottom)
  if not t:is_open() then t:open() end
  t:send("clear; " .. runner(file, out), false)
end

local function send(lines)
  local t = term("bottom", bottom)
  if not t:is_open() then t:open() end
  t:send(lines, true) -- true = остаться в текущем окне
end

local function send_line()
  send(vim.api.nvim_get_current_line())
end

local function send_selection()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  send(lines)
end

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec", "ToggleTermSendCurrentLine", "ToggleTermSendVisualSelection" },
    keys = {
      { "<C-\\>", toggle("float", float), mode = { "n", "t" }, desc = "Терминал плавающий" },
      { "<A-i>", toggle("float", float), mode = { "n", "t" }, desc = "Терминал плавающий" },
      { "<A-h>", toggle("bottom", bottom), mode = { "n", "t" }, desc = "Терминал снизу" },
      { "<A-v>", toggle("side", side), mode = { "n", "t" }, desc = "Терминал сбоку" },
      { "<leader>tf", toggle("float", float), desc = "Терминал плавающий" },
      { "<leader>tb", toggle("bottom", bottom), desc = "Терминал снизу" },
      { "<leader>tv", toggle("side", side), desc = "Терминал сбоку" },
      { "<leader>tg", toggle("lazygit", { cmd = "lazygit", direction = "float", count = 104 }), desc = "Lazygit" },
      { "<leader>gg", toggle("lazygit", { cmd = "lazygit", direction = "float", count = 104 }), desc = "Lazygit" },
      { "<leader>tl", send_line, desc = "Отправить строку в нижний терминал" },
      { "<leader>tl", send_selection, mode = "v", desc = "Отправить выделение в нижний терминал" },
      { "<leader>rr", run_file, desc = "Запустить текущий файл" },
      { "<leader>ta", "<cmd>TermSelect<cr>", desc = "Выбрать терминал" },
    },
    opts = {
      size = function(t)
        if t.direction == "horizontal" then return 15 end
        if t.direction == "vertical" then return math.floor(vim.o.columns * 0.4) end
      end,
      shade_terminals = false,
      start_in_insert = true,
      persist_mode = false,
      float_opts = { border = "rounded", width = function() return math.floor(vim.o.columns * 0.85) end,
        height = function() return math.floor(vim.o.lines * 0.8) end },
      on_open = function(t)
        -- Окна из нижнего/бокового терминала: Ctrl-h/j/k/l.
        -- В плавающем не трогаем — там Ctrl-l (clear) и Ctrl-k нужны шеллу.
        if t.direction == "float" then return end
        local o = { buffer = t.bufnr }
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], o)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], o)
      end,
    },
  },
}
