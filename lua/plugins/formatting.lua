return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = {},
        -- JS/TS have no conform formatter: ESLint (@stylistic) formats them
        -- through the eslint LSP (see the linting.eslint extra).
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- eslint registers formatting dynamically with a "c:/..." glob that never
      -- matches Windows buffer paths ("C:\..."), so declare it statically.
      Snacks.util.lsp.on({ name = "eslint" }, function(_, client)
        client.server_capabilities.documentFormattingProvider = true
      end)
      -- vtsls only formats projects without ESLint; otherwise LazyVim's LSP
      -- fallback would format with vtsls after eslint and undo its changes.
      opts.format = opts.format or {}
      opts.format.filter = function(client)
        if client.name ~= "vtsls" then
          return true
        end
        local buf = vim.api.nvim_get_current_buf()
        return #vim.lsp.get_clients({ bufnr = buf, name = "eslint" }) == 0
      end
    end,
  },
}
