-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>tg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>tb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>th", builtin.help_tags, { desc = "Telescope help tags" })

-- Angular terminal at project root (for ng generate commands)
vim.keymap.set("n", "<leader>ng", function()
  local root = vim.fs.root(0, { "angular.json", "nx.json" }) or vim.fn.getcwd()
  Snacks.terminal(nil, { cwd = root })
end, { desc = "Terminal at Angular project root" })

-- Quickfix navigation (for Overseer build/test error jumping)
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix error" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix error" })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix list" })

--Moving lines
vim.keymap.set("n", "<A-j>", ":m +1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
