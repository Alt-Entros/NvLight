-- Стартовая страница (snacks.nvim). Из snacks берём только dashboard,
-- удаление буферов без поломки раскладки и защиту от огромных файлов.
local t = require("config.i18n").t
return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            { icon = " ", key = "f", desc = t("Find file"), action = ":Telescope find_files" },
            { icon = " ", key = "n", desc = t("New file"), action = ":ene | startinsert" },
            { icon = " ", key = "r", desc = t("Recent files"), action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = t("Find text"), action = ":Telescope live_grep" },
            { icon = " ", key = "e", desc = t("File tree"), action = ":NvimTreeOpen" },
            { icon = " ", key = "t", desc = t("Change theme"), action = function() require("config.theme").pick() end },
            { icon = " ", key = "c", desc = t("Config"), action = function()
                require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
              end },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
            { icon = " ", key = "q", desc = t("Quit"), action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = t("Recent files"), section = "recent_files", cwd = true, limit = 6, indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
