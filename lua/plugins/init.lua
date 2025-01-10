---
-- @file lua/plugins/init.lua
--
-- @brief The initialization file to load external plugins
--
-- @author Rezha Adrian Tanuharja
-- @date 2024-08-31
--



local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- install lazy from github repository if it is not installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then

  -- github repository for lazy
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

  -- command to clone repository
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end

end

vim.opt.rtp:prepend(lazypath)

-- use protected call to load lazy
local success, lazy = pcall(require, 'lazy')
if not success then
  vim.notify('Failed to load plugin: lazy')
  return
end

-- all plugin settings are in this directory
local location = 'plugins.'

-- specify manually the plugins to load
lazy.setup {

  dev = {
    path = '~/.config/nvim/projects',
    fallback = false,
  },

  lockfile = nil,

  rocks = {
    enabled = false,
    hererocks = false,
  },

  ui = {
    border = 'single',
    icons = {
      cmd = '',
      config = '',
      event = '',
      favorite = '',
      ft = '',
      init = '',
      import = '',
      keys = '',
      lazy = '',
      loaded = '●',
      not_loaded = "○",
      plugin = "",
      runtime = "",
      require = "",
      source = "",
      start = "",
      task = "✔ ",
      list = {
        "●",
        "➜",
        "★",
        "‒",
      },
    },
  },

  change_detection = {
    enabled = false,
    notify = false,
  },

  performance = {

    cache = {
      enabled = true,
    },

    reset_packpath = true,

    rtp = {
      reset = true,
      disabled_plugins = {
        'editorconfig',
        'gzip',
        'man',
        'matchit',
        'netrwPlugin',
        'rplugin',
        'spellfile',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },

  },

  spec = {

    { import = location .. 'blink' },
    { import = location .. 'gitsigns' },
    { import = location .. 'autopairs' },
    { import = location .. 'treesitter' },
    { import = location .. 'bbye' },
    { import = location .. 'blankline' },
    { import = location .. 'nvim-tree' },
    { import = location .. 'nvim-dap' },
    { import = location .. 'vimtex' },
    { import = location .. 'developers.init' },
    { import = location .. 'terminal' },
    { import = location .. 'haskell' },
    { import = location .. 'telescope' },
    { import = location .. 'lint' },  
    { import = location .. 'format' },
},

  install = { colorscheme = { 'default' } },

}


require('lint').linters_by_ft = {
  markdown = {'hlint'},
}
-- au BufWritePost * lua require('lint').try_lint()

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()

    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()

    -- You can call `try_lint` with a linter name or a list of names to always
    -- run specific linters, independent of the `linters_by_ft` configuration
    require("lint").try_lint("hlint")
  end,
})

local lint_progress = function()
  local linters = require("lint").get_running()
  if #linters == 0 then
      return "󰦕"
  end
  return "󱉶 " .. table.concat(linters, ", ")
end


local ht = require('haskell-tools')
--- Start or attach the LSP client.
ht.lsp.start()

--- Stop the LSP client.
ht.lsp.stop()

--- Restart the LSP client.
ht.lsp.restart()

--- Callback for dynamically loading haskell-language-server settings
--- Falls back to the `hls.default_settings` if no file is found
--- or one is found, but it cannot be read or decoded.
--- @param project_root string? The project root
ht.lsp.load_hls_settings(project_root)

--- Evaluate all code snippets in comments
ht.lsp.buf_eval_all()


local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr, }
--vim.keymap.set('n', '<TAB>', ht.lsp.complete, opts)


require("conform").setup({
  formatters_by_ft = {
    haskell = {"ormolu"},
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
})


vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
