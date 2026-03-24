return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Extend vtsls with Angular language server plugin
      LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "@angular/language-server",
          location = LazyVim.get_pkg_path("angular-language-server", "/node_modules/@angular/language-server"),
          enableForWorkspaceTypeScriptVersions = false,
        },
      })

      -- Angular LSP server config
      opts.servers = opts.servers or {}
      opts.servers.angularls = {}

      -- Angular LSP setup
      opts.setup = opts.setup or {}
      opts.setup.angularls = function()
        Snacks.util.lsp.on({ name = "angularls" }, function(_, client)
          -- HACK: disable angular renaming capability due to duplicate rename popping up
          client.server_capabilities.renameProvider = false
          client.server_capabilities.completionProvider = nil
        end)
      end
    end,
  },
}
