-- Markdown как в Obsidian:
--   render-markdown.nvim — рендер прямо в буфере (заголовки, callout'ы > [!note],
--     чекбоксы, таблицы, код). На строке с курсором виден исходный текст —
--     как Live Preview в Obsidian.
--   snacks.image — картинки ![](img.png) и ![[img.png]] прямо в тексте (kitty, wezterm, ghostty).
--   markdown-oxide (LSP, ставится через Mason, см. lsp.lua) — автодополнение [[ссылок]],
--     gd/gR, теги, ежедневные заметки.
--   lua/config/markdown.lua — Enter по ссылке, обратные ссылки, чекбоксы, поиск по заметкам.
local t = require("config.i18n").t
local md = function(fn) return function() require("config.markdown")[fn]() end end

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      preset = "obsidian",
      completions = { lsp = { enabled = true } }, -- дополнение callout'ов и чекбоксов
      heading = { sign = false },
      code = { sign = false, width = "block", right_pad = 1 },
      latex = { enabled = false }, -- нужен внешний конвертер; формулы покажет snacks.image
    },
  },

  -- Картинки в markdown (kitty / wezterm / ghostty). PNG показывается как есть,
  -- для jpg/gif/svg/pdf и формул нужен ImageMagick: brew install imagemagick
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = { inline = true, max_width = 80, max_height = 30 },
        -- ![[img.png]] в Obsidian ищется по имени во всём хранилище
        resolve = function(file, src)
          if src:find("^%a[%w+.-]*://") or src:find("/") then return end
          local dir = vim.fs.dirname(file)
          if vim.uv.fs_stat(dir .. "/" .. src) then return end
          local root = vim.fs.root(file, { ".obsidian" })
          if not root then return end
          return vim.fs.find(src, { path = root, type = "file", limit = 1 })[1]
        end,
      },
    },
  },

  -- Заметки: глобальные клавиши (в markdown-буфере есть ещё Enter, gf, <leader>mb/mc/mo/mr)
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>mf", md("find_notes"), desc = t("Find notes") },
      { "<leader>mg", md("grep_notes"), desc = t("Search notes") },
      { "<leader>mt", md("tags"), desc = t("Tags") },
      { "<leader>md", md("daily"), desc = t("Daily note") },
    },
  },
}
