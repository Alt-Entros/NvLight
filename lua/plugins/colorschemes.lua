-- Набор тем для <leader>th. Хочешь ещё — добавь репозиторий сюда,
-- он сам появится в пикере. Грузятся сразу (lazy = false), иначе пикер их не увидит;
-- на скорость старта почти не влияет — код темы выполняется только при выборе.
return {
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = { style = "night" } },
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000 },
  { "navarasu/onedark.nvim", lazy = false, priority = 1000, opts = { style = "darker" } },
  { "sainnhe/gruvbox-material", lazy = false, priority = 1000 },
  { "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
}
