-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>tg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>tb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>th", builtin.help_tags, { desc = "Telescope help tags" })
