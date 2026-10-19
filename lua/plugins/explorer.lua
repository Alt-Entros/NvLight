-- Дерево файлов — тот же nvim-tree, что и в NvChad
local t = require("config.i18n").t
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen", "NvimTreeFindFile" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = t("Toggle file tree") },
      { "<leader>e", "<cmd>NvimTreeFocus<cr>", desc = t("Focus file tree") },
    },
    init = function()
      -- netrw выключаем, чтобы `nvim .` открывал nvim-tree
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      view = { width = 32, preserve_window_proportions = true },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = { enable = true },
        icons = { git_placement = "after" },
      },
      git = { enable = true, ignore = false }, -- показывать файлы из .gitignore (приглушённо)
      diagnostics = { enable = true, show_on_dirs = true },
      filters = { dotfiles = false, custom = { "^.git$", "^.DS_Store$" } },
      actions = { open_file = { quit_on_open = false } },
    },
  },
}
