-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      angularls = {
        -- your overrides here
      },
    },
  },
}
