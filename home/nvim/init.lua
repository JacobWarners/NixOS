-- File: nvim/init.lua
-- Load basic editor options first
require("options")
-- No bootstrapping needed, home-manager installs lazy.nvim for us.
-- This tells lazy.nvim to load all .lua files from the 'plugins' directory.
require("lazy").setup("plugins")
