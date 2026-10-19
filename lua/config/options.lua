local o = vim.opt

-- Внешний вид
o.number = true
o.relativenumber = true
o.numberwidth = 4
o.signcolumn = "yes"
o.cursorline = true
o.cursorlineopt = "both"
o.termguicolors = true
o.showmode = false -- режим показывает lualine
o.laststatus = 3 -- одна статусная строка на всё окно
o.cmdheight = 1
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false
o.fillchars = { eob = " " }
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.winborder = "rounded" -- рамки у hover/signature/float (nvim 0.11+)

-- Отступы (по умолчанию 2, для C/C++/C#/Python — 4, см. autocmds)
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

-- Поиск
o.ignorecase = true
o.smartcase = true
o.inccommand = "split" -- превью :s/// в отдельном окне

-- Поведение
o.mouse = "a"
o.undofile = true
o.swapfile = false
o.splitright = true
o.splitbelow = true
o.updatetime = 250
o.timeoutlen = 400
o.confirm = true -- спрашивать вместо ошибки при :q с изменениями
o.completeopt = { "menu", "menuone", "noselect" }
o.foldlevel = 99

-- ── Системный буфер обмена ───────────────────────────────────────────
-- y/p/d работают с буфером macOS (pbcopy/pbpaste).
-- Ставим через schedule, чтобы не тормозить старт.
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- По SSH (Arch-серверы): копирование через OSC 52 прямо в буфер Mac.
-- Вставка — из внутреннего регистра (OSC 52 paste в kitty требует подтверждения),
-- а из системного буфера на сервер вставляй обычным Cmd+V терминала.
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

-- ── Windows: PowerShell вместо cmd.exe ───────────────────────────────
-- Терминалы, запуск файлов и :! работают через pwsh (PowerShell 7),
-- если его нет — через встроенный Windows PowerShell. Рецепт из :help shell-powershell
if vim.fn.has("win32") == 1 then
  local pwsh = vim.fn.executable("pwsh") == 1
  o.shell = pwsh and "pwsh" or "powershell"
  o.shellcmdflag = "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
    .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
    .. (pwsh and "$PSStyle.OutputRendering='plaintext';" or "") -- $PSStyle есть только в PowerShell 7
    .. "Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
  o.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  o.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
  o.shellquote = ""
  o.shellxquote = ""
end

-- Отключаем неиспользуемые провайдеры (как было в NvChad)
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
