-- Settings / Настройки
--
-- Defaults live here. To change something only for yourself, copy
-- lua/user.example.lua → lua/user.lua and edit it there: user.lua is in
-- .gitignore, so `git pull` never conflicts with your changes.
--
-- Значения по умолчанию — здесь. Чтобы поменять что-то только у себя,
-- скопируй lua/user.example.lua → lua/user.lua и правь там: user.lua в
-- .gitignore, поэтому `git pull` не будет конфликтовать с твоими правками.

local defaults = {
  -- Interface language: "en" | "ru" (restart nvim after changing)
  language = "en",

  -- Theme used until you pick another one with <leader>th
  theme = "tokyonight-night",

  -- Transparent background (toggle at runtime: <leader>ut)
  transparent = true,

  -- Format on save (toggle at runtime: <leader>uf)
  format_on_save = true,
}

local ok, user = pcall(require, "user")
if ok and type(user) == "table" then
  return vim.tbl_deep_extend("force", defaults, user)
end
if not ok and not tostring(user):find("module 'user' not found", 1, true) then
  vim.schedule(function()
    vim.notify("lua/user.lua: " .. tostring(user), vim.log.levels.ERROR)
  end)
end
return defaults
