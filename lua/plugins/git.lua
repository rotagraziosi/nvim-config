return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gblame" },
  keys = {
    { "<leader>gzs", "<cmd>Git<cr>", desc = "Fugitive status" },
    { "<leader>gzD", "<cmd>Gvdiffsplit<cr>", desc = "Fugitive diff split" },
  },
}
