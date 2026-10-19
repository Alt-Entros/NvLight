-- Автодополнение: blink.cmp (быстрее и проще nvim-cmp из NvChad)
-- Enter — принять, Tab/Shift-Tab — по списку и по полям сниппета,
-- Ctrl-Space — открыть меню вручную, Ctrl-e — закрыть, Ctrl-k — сигнатура
return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- готовый бинарник fuzzy-матчера, без сборки Rust
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        menu = {
          border = "rounded",
          draw = { treesitter = { "lsp" }, columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } } },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        accept = { auto_brackets = { enabled = true } },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      cmdline = {
        keymap = { preset = "inherit" },
        -- без предвыбора: Enter выполняет набранную команду, а не первую подсказку
        completion = { menu = { auto_show = true }, list = { selection = { preselect = false } } },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  -- Автозакрытие скобок и кавычек
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },
}
