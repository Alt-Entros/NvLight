-- LSP: ставится и включается автоматически.
--   mason            — менеджер бинарников (LSP, форматтеры, линтеры)
--   mason-lspconfig  — ставит LSP из списка ниже и сам делает vim.lsp.enable()
--   mason-tool-installer — ставит форматтеры/линтеры
-- Чтобы добавить язык: допиши сервер в `servers` (имя из :help lspconfig-all
-- или из :Mason), при необходимости — настройки в vim.lsp.config ниже.
local t = require("config.i18n").t

-- LSP-серверы (имена nvim-lspconfig)
local servers = {
  -- C / C++
  "clangd",
  -- Python
  "basedpyright", -- типы, автодополнение, переходы
  "ruff", -- линт + форматирование + сортировка импортов
  -- Конфиги и DevOps
  "dockerls",
  "docker_compose_language_service",
  "yamlls",
  "jsonls",
  "ansiblels",
  "bashls",
  "taplo", -- TOML
  "nginx_language_server",
  -- Lua (для правки самого конфига)
  "lua_ls",
  -- Веб (было в старом конфиге)
  "vtsls",
  "vue_ls",
  "html",
  "cssls",
  "tailwindcss",
  "eslint",
}

-- Форматтеры, линтеры и прочее (имена пакетов Mason)
local tools = {
  "clang-format",
  "csharpier",
  "stylua",
  "prettier",
  "shfmt",
  "shellcheck", -- bashls подхватывает автоматически
  "hadolint", -- линтер Dockerfile
  "ansible-lint", -- ansiblels подхватывает автоматически
  "roslyn", -- LSP для C# (реестр Crashdummyy, запускается через roslyn.nvim)
  "tree-sitter-cli", -- нужен nvim-treesitter для сборки парсеров
}

local function setup_diagnostics()
  local icons = { ERROR = " ", WARN = " ", INFO = " ", HINT = "󰌵 " }
  vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    underline = true,
    virtual_text = { spacing = 2, prefix = "●", source = "if_many" },
    virtual_lines = false, -- <leader>ul — показывать ошибку полной строкой под кодом
    float = { border = "rounded", source = true },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.ERROR,
        [vim.diagnostic.severity.WARN] = icons.WARN,
        [vim.diagnostic.severity.INFO] = icons.INFO,
        [vim.diagnostic.severity.HINT] = icons.HINT,
      },
    },
  })
end

local function on_attach(args)
  local buf = args.buf
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if not client then return end

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end
  local tb = function(name) return function() require("telescope.builtin")[name]() end end

  -- Переходы (через telescope — если вариантов несколько, будет список с превью)
  map("n", "gd", tb("lsp_definitions"), t("Go to definition"))
  map("n", "gD", vim.lsp.buf.declaration, t("Go to declaration"))
  map("n", "gI", tb("lsp_implementations"), t("Implementations"))
  map("n", "gy", tb("lsp_type_definitions"), t("Type definition"))
  map("n", "gR", tb("lsp_references"), t("References"))
  -- K — документация, grn — переименовать, gra — code action, grr — ссылки:
  -- встроены в nvim 0.11+, ниже дублирую на <leader>l для which-key

  map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, t("Code action"))
  map("n", "<leader>lr", vim.lsp.buf.rename, t("Rename"))
  map("n", "<leader>lk", vim.lsp.buf.signature_help, t("Signature help"))
  map("n", "<leader>li", "<cmd>checkhealth vim.lsp<cr>", t("LSP info"))
  map("n", "<leader>lR", "<cmd>LspRestart<cr>", t("Restart LSP"))
  map("n", "<leader>lh", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
  end, t("Toggle inlay hints"))

  if client.name == "clangd" then
    map("n", "<leader>lo", "<cmd>LspClangdSwitchSourceHeader<cr>", t("C/C++: switch header/source"))
  end

  -- Подсветка всех вхождений слова под курсором
  if client:supports_method("textDocument/documentHighlight", buf) then
    local grp = vim.api.nvim_create_augroup("lsp_highlight_" .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = grp, buffer = buf, callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = grp, buffer = buf, callback = vim.lsp.buf.clear_references,
    })
  end

  -- Hover документации отдаёт basedpyright, у ruff он хуже
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false
  end
end

return {
  {
    "mason-org/mason.nvim",
    lazy = false, -- добавляет бинарники Mason в PATH, нужно сразу
    build = ":MasonUpdate",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry", -- roslyn
      },
      ui = { border = "rounded" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    -- VeryLazy — чтобы установка LSP стартовала даже со стартовой страницы
    event = { "BufReadPre", "BufNewFile", "VeryLazy" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "b0o/SchemaStore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      setup_diagnostics()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = on_attach,
      })

      -- Общие возможности клиента (автодополнение из blink.cmp)
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- ── Настройки отдельных серверов ──────────────────────────────
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard", -- "strict" слишком шумный для учёбы
              autoImportCompletions = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { disable = { "missing-fields" } },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            keyOrdering = false,
            schemaStore = { enable = false, url = "" }, -- используем SchemaStore.nvim
            schemas = require("schemastore").yaml.schemas(),
          },
          redhat = { telemetry = { enabled = false } },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      -- Vue 3: vtsls + плагин @vue/typescript-plugin из пакета vue-language-server.
      -- (в старом конфиге vue_plugin_path был не объявлен — поэтому не работало)
      vim.lsp.config("vtsls", {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vim.fn.stdpath("data")
                    .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                  languages = { "vue" },
                  configNamespace = "typescript",
                },
              },
            },
          },
        },
      })

      -- C# (roslyn.nvim сам находит .sln/.csproj и запускает сервер)
      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
          ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
          },
        },
      })

      -- ── Установка и автозапуск ──────────────────────────────────
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true, -- всё установленное через Mason запускается само
      })
      require("mason-tool-installer").setup({
        ensure_installed = tools,
        run_on_start = true,
      })
    end,
  },

  -- C#
  { "seblyng/roslyn.nvim", ft = { "cs", "razor" }, opts = {} },

  -- Автодополнение и типы для vim.* при правке конфига nvim
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
  },
}
