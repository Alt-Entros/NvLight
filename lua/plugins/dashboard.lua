-- Стартовая страница (snacks.nvim). Из snacks берём только dashboard,
-- удаление буферов без поломки раскладки и защиту от огромных файлов.
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
            { icon = " ", key = "f", desc = "Найти файл", action = ":Telescope find_files" },
            { icon = " ", key = "n", desc = "Новый файл", action = ":ene | startinsert" },
            { icon = " ", key = "r", desc = "Недавние файлы", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "Поиск по тексту", action = ":Telescope live_grep" },
            { icon = " ", key = "e", desc = "Дерево файлов", action = ":NvimTreeOpen" },
            { icon = " ", key = "t", desc = "Сменить тему", action = function() require("config.theme").pick() end },
            { icon = " ", key = "c", desc = "Конфиг nvim", action = function()
                require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
              end },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
            { icon = " ", key = "q", desc = "Выход", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = "Недавние файлы", section = "recent_files", cwd = true, limit = 6, indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
