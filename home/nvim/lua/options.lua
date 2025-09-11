-- File: nvim/lua/options.lua

-- Set editor options
vim.opt.syntax = "on"         -- equivalent to 'syntax on'
vim.opt.background = "dark"   -- equivalent to 'set background=dark'
vim.opt.number = true         -- equivalent to 'set number'
vim.opt.cursorline = true     -- equivalent to 'set cursorline'
vim.opt.showmatch = true      -- equivalent to 'set showmatch'
vim.opt.mouse = "a"           -- equivalent to 'set mouse=a'
vim.opt.clipboard = "unnamedplus" -- equivalent to 'set clipboard+=unnamedplus'

-- Set colorscheme
vim.cmd("colorscheme gruvbox")

-- Custom keybindings
-- Exit file explorer with Q
vim.keymap.set("n", "Q", ":Rexplore<CR>", { noremap = true, silent = true })
-- Use jj to escape insert mode
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
