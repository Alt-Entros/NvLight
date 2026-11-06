-- Заметки в стиле Obsidian: переход по [[ссылкам]], обратные ссылки, чекбоксы.
-- Хранилище (vault) — ближайшая папка вверх с .obsidian / .moxide.toml / .git,
-- иначе папка текущего файла. Работает и без LSP (markdown-oxide только дополняет).
local t = require("config.i18n").t

local M = {}

local root_markers = { ".obsidian", ".moxide.toml", ".git" }

---Корень хранилища для файла/буфера.
---@param buf? integer
---@return string
function M.root(buf)
  local file = vim.api.nvim_buf_get_name(buf or 0)
  if file == "" then return vim.fn.getcwd() end
  return vim.fs.root(file, root_markers) or vim.fs.dirname(file)
end

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

-- Сравнение заголовков без учёта регистра, пробелов и знаков:
-- "My Heading" == "my-heading" (якорь из [текст](файл.md#my-heading))
local function norm(s)
  return (vim.fn.tolower(s):gsub("[%s%p]", ""))
end

---Перейти к заголовку (#Заголовок) или блоку (#^id) в текущем буфере.
local function goto_anchor(anchor)
  if not anchor or anchor == "" then return end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local block = anchor:match("^%^(.+)")
  local want = norm(anchor)
  for i, line in ipairs(lines) do
    local found
    if block then
      found = line:find("%^" .. vim.pesc(block) .. "%s*$") ~= nil
    else
      local text = line:match("^#+%s+(.-)%s*$")
      found = text ~= nil and norm(text) == want
    end
    if found then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.cmd("normal! zvzt")
      return
    end
  end
  vim.notify(t("Heading not found") .. ": " .. anchor, vim.log.levels.WARN)
end

---Найти файл заметки по ссылке. Порядок — как в Obsidian: рядом с текущим
---файлом, от корня хранилища, затем по имени в любом подкаталоге.
---@return string? path
---@return string candidate путь, по которому создать заметку, если её нет
local function find_note(name, buf)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  local root = M.root(buf)
  local has_ext = vim.fs.basename(name):find("%.%w+$") ~= nil
  local file = has_ext and name or (name .. ".md")

  for _, base in ipairs({ dir, root }) do
    local p = vim.fs.normalize(base .. "/" .. file)
    if vim.uv.fs_stat(p) then return p end
  end
  local found = vim.fs.find(vim.fs.basename(file), { path = root, type = "file", limit = 1 })[1]
  return found, vim.fs.normalize(root .. "/" .. file)
end

local function open_path(path, anchor, candidate)
  local ext = (path or candidate):match("%.(%w+)$")
  if path and ext and ext:lower() ~= "md" then
    vim.ui.open(path) -- картинки, pdf и т.п. — системной программой
    return
  end
  vim.cmd("normal! m'") -- чтобы <C-o> вернул назад
  if not path then
    vim.notify(t("New note") .. ": " .. vim.fn.fnamemodify(candidate, ":~:."))
  end
  vim.cmd.edit(vim.fn.fnameescape(path or candidate))
  goto_anchor(anchor)
end

---Ссылка под курсором: { kind = "wiki"|"md"|"url", target = "..." }
local function link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local patterns = {
    { "wiki", "!?%[%[(.-)%]%]" },
    { "md", "!?%[[^%]]-%]%((.-)%)" },
    { "url", "(%a[%w+.-]*://[^%s<>%)%]]+)" },
  }
  for _, p in ipairs(patterns) do
    local init = 1
    while true do
      local s, e, cap = line:find(p[2], init)
      if not s then break end
      if col >= s and col <= e then return { kind = p[1], target = cap } end
      init = e + 1
    end
  end
end

---Открыть ссылку под курсором. Возвращает false, если курсор не на ссылке.
function M.follow()
  local link = link_under_cursor()
  if not link then return false end
  local buf = vim.api.nvim_get_current_buf()
  local target = vim.trim(link.target)

  if link.kind == "url" or target:match("^%a[%w+.-]*:") then
    target = target:match("^<?(.-)>?$")
    if link.kind == "url" then target = target:gsub("[.,;:!?]+$", "") end -- точка в конце предложения
    vim.ui.open(target)
    return true
  end

  if link.kind == "wiki" then
    target = target:gsub("|.*$", "") -- [[заметка|текст]]
  else
    target = url_decode(target:match("^<?(.-)>?$"):gsub('%s+".*"$', "")) -- (путь "title")
  end

  local name, anchor = target:match("^(.-)#(.*)$")
  name = name or target
  if name == "" then -- [[#Заголовок]] — ссылка внутри файла
    vim.cmd("normal! m'")
    goto_anchor(anchor)
    return true
  end

  if link.kind == "md" then
    local dir = name:sub(1, 1) == "/" and M.root(buf) or vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
    local path = vim.fs.normalize(dir .. "/" .. name)
    if vim.uv.fs_stat(path) then
      open_path(path, anchor, path)
    else
      -- [текст](Заметка) без .md — ищем как wiki-ссылку
      local found, candidate = find_note((name:gsub("%.md$", "")), buf)
      open_path(found, anchor, candidate)
    end
  else
    local found, candidate = find_note(name, buf)
    open_path(found, anchor, candidate)
  end
  return true
end

---Переключить чекбокс в строке: [ ] → [x] → [ ]; у пункта списка без
---чекбокса — добавить его.
function M.toggle_checkbox()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local list = "^(%s*[-*+] )"
  local olist = "^(%s*%d+[.)] )"
  local new
  for _, prefix in ipairs({ list, olist }) do
    if line:match(prefix .. "%[ %]") then
      new = line:gsub(prefix .. "%[ %]", "%1[x]", 1)
    elseif line:match(prefix .. "%[.%]") then
      new = line:gsub(prefix .. "%[.%]", "%1[ ]", 1)
    elseif line:match(prefix) then
      new = line:gsub(prefix, "%1[ ] ", 1)
    end
    if new then break end
  end
  if not new then return false end
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new })
  return true
end

---Enter: открыть ссылку, отметить чекбокс, иначе — обычный Enter.
function M.enter()
  if M.follow() then return end
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*[-*+] %[.%]") or line:match("^%s*%d+[.)] %[.%]") then
    M.toggle_checkbox()
    return
  end
  vim.cmd("normal! " .. vim.v.count1 .. "+") -- обычный <CR>: на строку ниже
end

local function rg_escape(s)
  return (s:gsub("[%^%$%(%)%.%[%]%*%+%-%?%{%}%|\\]", "\\%0"))
end

---Обратные ссылки: какие заметки ссылаются на текущую.
function M.backlinks()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then return end
  local name = vim.fn.fnamemodify(file, ":t:r")
  local n = rg_escape(name):gsub(" ", "(?: |%%20)")
  local pattern = table.concat({
    "\\[\\[(?:[^\\]|#]*/)?" .. n .. "(?:\\.md)?(?:[#|][^\\]]*)?\\]\\]", -- [[name]], [[dir/name#h|alias]]
    "\\]\\((?:[^)]*/)?" .. n .. "(?:\\.md)?(?:#[^)]*)?\\)", -- [text](dir/name.md#h)
  }, "|")
  require("telescope.builtin").grep_string({
    prompt_title = t("Backlinks") .. ": " .. name,
    search = pattern,
    use_regex = true,
    cwd = M.root(),
    additional_args = { "--glob=*.md", "--ignore-case" },
  })
end

function M.find_notes()
  require("telescope.builtin").find_files({
    prompt_title = t("Notes"),
    cwd = M.root(),
    find_command = { "rg", "--files", "--glob=*.md" },
  })
end

function M.grep_notes()
  require("telescope.builtin").live_grep({
    prompt_title = t("Search notes"),
    cwd = M.root(),
    glob_pattern = "*.md",
  })
end

---Теги: все #теги хранилища, Enter — где встречается тег.
function M.tags()
  require("telescope.builtin").grep_string({
    prompt_title = t("Tags"),
    search = "(?:^|\\s)#[\\p{L}\\d_/-]*\\p{L}[\\p{L}\\d_/-]*",
    use_regex = true,
    cwd = M.root(),
    additional_args = { "--glob=*.md" },
  })
end

---Ежедневная заметка: markdown-oxide (учитывает настройки .obsidian),
---иначе <хранилище>/ГГГГ-ММ-ДД.md
function M.daily()
  if vim.fn.exists(":LspToday") == 2 then
    vim.cmd("LspToday")
    return
  end
  open_path(nil, nil, vim.fs.normalize(M.root() .. "/" .. os.date("%Y-%m-%d") .. ".md"))
end

---Клавиши и опции окна для markdown-буфера.
function M.attach(buf)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true -- перенос по словам
  vim.opt_local.breakindent = true

  map("n", "<CR>", M.enter, t("Follow link / toggle checkbox"))
  map("n", "gf", function()
    if not M.follow() then vim.cmd("normal! gf") end
  end, t("Follow link"))
  map("n", "<leader>mc", M.toggle_checkbox, t("Toggle checkbox"))
  map("n", "<leader>mb", M.backlinks, t("Backlinks"))
  vim.keymap.set("n", "<leader>mo", "gO", { buffer = buf, remap = true, desc = t("Outline (headings)") })
  map("n", "<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", t("Toggle rendering"))
end

return M
