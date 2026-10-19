-- Interface translations.
-- All UI strings in the config are written in English and wrapped in t("...").
-- For another language t() looks the string up in lua/config/locales/<language>.lua;
-- anything missing there falls back to English.
--
-- Adding a language: create locales/<code>.lua returning { ["English text"] = "Translation" }
-- and set language = "<code>" in lua/user.lua.

local M = {}

local lang = require("config.settings").language or "en"
local dict = {}

if lang ~= "en" then
  local ok, loaded = pcall(require, "config.locales." .. lang)
  if ok and type(loaded) == "table" then
    dict = loaded
  else
    vim.schedule(function()
      vim.notify("i18n: locale '" .. lang .. "' not found, using English", vim.log.levels.WARN)
    end)
  end
end

M.lang = lang

---Translate a UI string.
---@param s string English text
---@return string
function M.t(s)
  return dict[s] or s
end

return M
