-- Аналог NvChad base46-пикера:
--   <leader>th — выбрать тему с живым превью (сохраняется между запусками)
--   <leader>ut — включить/выключить прозрачный фон (тоже сохраняется)
-- Состояние лежит в ~/.local/share/nvim/theme.json

local M = {}

local state_file = vim.fn.stdpath("data") .. "/theme.json"
local default = { name = "tokyonight-night", transparent = true }

M.state = vim.deepcopy(default)

local function read_state()
  local f = io.open(state_file, "r")
  if not f then return end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if ok and type(data) == "table" then
    M.state = vim.tbl_extend("force", M.state, data)
  end
end

local function write_state()
  local f = io.open(state_file, "w")
  if not f then return end
  f:write(vim.json.encode(M.state))
  f:close()
end

-- Группы, у которых убираем фон в прозрачном режиме.
-- Плавающие окна (telescope, автодополнение) оставляем с фоном — так читабельнее.
local transparent_groups = {
  "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "LineNr", "CursorLineNr",
  "FoldColumn", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill",
  "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeEndOfBuffer", "NvimTreeWinSeparator",
  "WinSeparator", "BufferLineFill", "SnacksDashboardNormal",
  "GitSignsAdd", "GitSignsChange", "GitSignsDelete",
  "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint",
}

function M.apply_transparency()
  if not M.state.transparent then return end
  for _, group in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
      hl.bg = nil
      hl.ctermbg = nil
      ---@diagnostic disable-next-line: param-type-mismatch
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

function M.toggle_transparency()
  M.state.transparent = not M.state.transparent
  write_state()
  -- перезагружаем тему, чтобы вернуть фон, если прозрачность выключили
  vim.cmd.colorscheme(vim.g.colors_name or M.state.name)
  vim.notify("Прозрачность: " .. (M.state.transparent and "вкл" or "выкл"))
end

function M.pick()
  require("telescope.builtin").colorscheme({
    enable_preview = true,
    ignore_builtins = true, -- скрыть встроенные blue/darkblue/... темы
  })
end

function M.setup()
  read_state()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("user_theme", { clear = true }),
    callback = function(args)
      M.apply_transparency()
      -- Запоминаем выбор. При превью в пикере это тоже срабатывает,
      -- но при отмене telescope возвращает исходную тему — и она запишется обратно.
      if args.match and args.match ~= "" and args.match ~= M.state.name then
        M.state.name = args.match
        write_state()
      end
    end,
  })

  if not pcall(vim.cmd.colorscheme, M.state.name) then
    vim.notify("Тема " .. M.state.name .. " не найдена, ставлю " .. default.name, vim.log.levels.WARN)
    pcall(vim.cmd.colorscheme, default.name)
  end
end

return M
