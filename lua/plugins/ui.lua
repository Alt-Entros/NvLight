local t = require("config.i18n").t
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Подсказка по клавишам: нажми <leader> (пробел) и подожди — появится меню
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
      spec = {
        { "<leader>f", group = t("Find (telescope)") },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>d", group = t("Diagnostics") },
        { "<leader>t", group = t("Terminal / themes") },
        { "<leader>u", group = t("UI toggles") },
        { "<leader>s", group = t("Splits") },
        { "<leader>r", group = t("Run") },
        { "<leader>h", group = "Git hunks" },
        { "<leader>b", group = t("Buffers") },
        { "<leader>w", group = "which-key" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = t("Buffer keymaps") },
      { "<leader>wK", function() require("which-key").show() end, desc = t("All keymaps (which-key)") },
    },
  },

  -- Статусная строка
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local function lsp_names()
        local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
        return #names > 0 and (" " .. table.concat(names, ", ")) or ""
      end
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = "",
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 }, "diagnostics" },
          lualine_x = { lsp_names, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "nvim-tree", "toggleterm", "lazy", "mason", "trouble" },
      }
    end,
  },

  -- Вкладки буферов сверху (как tabufline в NvChad)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = t("Next buffer") },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = t("Previous buffer") },
      { "<leader>x", function() Snacks.bufdelete() end, desc = t("Close buffer") },
      { "<leader>X", function() Snacks.bufdelete.other() end, desc = t("Close other buffers") },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = t("Pin buffer") },
      { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = t("Pick buffer") },
    },
    opts = {
      options = {
        close_command = function(n) Snacks.bufdelete(n) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        offsets = { { filetype = "NvimTree", text = t("Files"), highlight = "Directory", separator = true } },
      },
    },
  },

  -- Git-метки на полях
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buf, desc = desc }) end
        map("n", "]h", function() gs.nav_hunk("next") end, t("Next hunk"))
        map("n", "[h", function() gs.nav_hunk("prev") end, t("Previous hunk"))
        map("n", "<leader>hp", gs.preview_hunk, t("Preview hunk"))
        map("n", "<leader>hr", gs.reset_hunk, t("Reset hunk"))
        map("n", "<leader>hs", gs.stage_hunk, t("Stage hunk"))
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, t("Blame line"))
        map("n", "<leader>hd", gs.diffthis, t("Diff file"))
      end,
    },
  },

  -- Список ошибок по проекту
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", desc = t("Project diagnostics (Trouble)") },
      { "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = t("Buffer diagnostics (Trouble)") },
      { "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", desc = t("Symbols outline") },
      { "<leader>dr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = t("LSP definitions/references") },
      { "<leader>dQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
    },
  },

  -- Направляющие отступов
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = { filetypes = { "snacks_dashboard", "help", "lazy", "mason", "NvimTree", "trouble" } },
    },
  },

  -- Подсветка TODO/FIXME/NOTE и поиск по ним
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = { { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = t("Project TODOs") } },
  },
}
