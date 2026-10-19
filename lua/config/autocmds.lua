local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Подсветка скопированного текста
au("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Возвращать курсор на место последнего редактирования
au("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[args.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 4 пробела для C / C++ / C# / Python (если нет .editorconfig — он главнее)
au("FileType", {
  group = group,
  pattern = { "c", "cpp", "cs", "python", "java", "nginx" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Закрывать служебные окна по q
au("FileType", {
  group = group,
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "notify", "startuptime" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})

-- Выравнивать сплиты при изменении размера терминала
au("VimResized", { group = group, command = "tabdo wincmd =" })

-- В терминале — без номеров строк, сразу в режим ввода
au("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})
