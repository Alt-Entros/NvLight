local t = require("config.i18n").t
local function tb(name, opts)
  return function() require("telescope.builtin")[name](opts or {}) end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      -- быстрый сортировщик; нужен make (на Windows без make просто не ставится,
      -- telescope работает со встроенным сортировщиком)
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = vim.fn.executable("make") == 1,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      -- Файлы и текст (раскладка как в NvChad)
      { "<leader>ff", tb("find_files"), desc = t("Find files") },
      { "<leader>fa", tb("find_files", { hidden = true, no_ignore = true }), desc = t("All files (incl. hidden & ignored)") },
      { "<leader>fw", tb("live_grep"), desc = t("Live grep") },
      { "<leader>fW", tb("grep_string"), desc = t("Grep word under cursor"), mode = { "n", "v" } },
      { "<leader>fz", tb("current_buffer_fuzzy_find"), desc = t("Search in current buffer") },
      { "<leader>fb", tb("buffers", { sort_mru = true, ignore_current_buffer = true }), desc = t("Open buffers") },
      { "<leader>fo", tb("oldfiles", { only_cwd = true }), desc = t("Recent files (project)") },
      { "<leader>fO", tb("oldfiles"), desc = t("Recent files (all)") },
      { "<leader>fr", tb("resume"), desc = t("Resume last search") },
      { "<leader><leader>", tb("buffers", { sort_mru = true, ignore_current_buffer = true }), desc = t("Buffers") },
      -- Справка и сам nvim
      { "<leader>fk", tb("keymaps"), desc = t("Keymaps") },
      { "<leader>fh", tb("help_tags"), desc = t("Help") },
      { "<leader>fc", tb("commands"), desc = t("Commands") },
      { "<leader>f:", tb("command_history"), desc = t("Command history") },
      { "<leader>fm", tb("marks"), desc = t("Marks") },
      { "<leader>fq", tb("quickfix"), desc = "Quickfix" },
      { "<leader>fn", function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end, desc = t("Neovim config files") },
      -- LSP
      { "<leader>fs", tb("lsp_document_symbols"), desc = t("Document symbols") },
      { "<leader>fS", tb("lsp_dynamic_workspace_symbols"), desc = t("Workspace symbols") },
      { "<leader>fd", tb("diagnostics", { bufnr = 0 }), desc = t("Buffer diagnostics") },
      { "<leader>fD", tb("diagnostics"), desc = t("Project diagnostics") },
      -- Git
      { "<leader>gs", tb("git_status"), desc = t("Git: status") },
      { "<leader>gc", tb("git_commits"), desc = t("Git: commits") },
      { "<leader>gC", tb("git_bcommits"), desc = t("Git: file commits") },
      { "<leader>gB", tb("git_branches"), desc = t("Git: branches") },
    },
    init = function()
      -- Code actions и прочие vim.ui.select сразу идут через telescope,
      -- даже если он ещё не загружен
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "telescope.nvim" } })
        return vim.ui.select(...)
      end
    end,
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local layout = require("telescope.actions.layout")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          entry_prefix = " ",
          sorting_strategy = "ascending",
          layout_strategy = "flex", -- широкое окно: превью справа, узкое: снизу
          layout_config = {
            prompt_position = "top",
            width = 0.9,
            height = 0.85,
            horizontal = { preview_width = 0.55 },
            flex = { flip_columns = 140 },
          },
          path_display = { "filename_first" },
          -- [/\\] — чтобы шаблоны работали и с путями Windows
          file_ignore_patterns = {
            "%.git[/\\]", "node_modules[/\\]", "%.cache[/\\]", "obj[/\\]",
            "bin[/\\]Debug[/\\]", "bin[/\\]Release[/\\]", "__pycache__[/\\]", "%.venv[/\\]",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename", "--line-number",
            "--column", "--smart-case", "--hidden", "--glob=!**/.git/*",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close, -- закрыть с одного Esc
              ["<C-p>"] = layout.toggle_preview,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-u>"] = false, -- очистить строку ввода, а не скроллить превью
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = { ["q"] = actions.close },
          },
        },
        pickers = {
          find_files = { hidden = true },
          buffers = { mappings = { i = { ["<C-d>"] = actions.delete_buffer } } },
          colorscheme = { layout_strategy = "vertical", layout_config = { width = 0.4, height = 0.6 }, previewer = false },
        },
        extensions = {
          fzf = {},
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
