-- Leader должен быть задан до загрузки плагинов
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.filetypes")
require("config.lazy")
require("config.theme").setup()
require("config.keymaps")
require("config.autocmds")
