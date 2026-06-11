return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Inject Angular language server as a vtsls plugin, using project node_modules
      -- so the version matches the project's Angular version
      LazyVim.extend(opts.servers.vtsls, "settings.vtsls.tsserver.globalPlugins", {
        {
          name = "@angular/language-server",
          location = LazyVim.get_pkg_path("angular-language-server", "/node_modules/@angular/language-server"),
          enableForWorkspaceTypeScriptVersions = false,
        },
      })

      -- Override the plugin location with the project's node_modules at runtime
      local vtsls_on_new_config = opts.servers.vtsls.on_new_config
      opts.servers.vtsls.on_new_config = function(new_config, new_root_dir)
        if vtsls_on_new_config then
          vtsls_on_new_config(new_config, new_root_dir)
        end
        local project_ng = new_root_dir .. "/node_modules/@angular/language-server"
        if vim.fn.isdirectory(project_ng) == 1 then
          local plugins = vim.tbl_get(
            new_config,
            "settings", "vtsls", "tsserver", "globalPlugins"
          ) or {}
          for _, plugin in ipairs(plugins) do
            if plugin.name == "@angular/language-server" then
              plugin.location = project_ng
            end
          end
        end
      end

      -- angularls: attach to typescript too so it can resolve template↔component
      -- definitions (gd in HTML → TS). Completions/hover on .ts are disabled
      -- via on_attach so vtsls stays in charge for TS editing.
      opts.servers.angularls = {
        filetypes = { "typescript", "html", "htmlangular" },
        on_new_config = function(new_config, new_root_dir)
          local project_node_modules = new_root_dir .. "/node_modules"
          local ngserver = LazyVim.get_pkg_path("angular-language-server", "/node_modules/.bin/ngserver")
          new_config.cmd = {
            ngserver,
            "--stdio",
            "--tsProbeLocations", project_node_modules,
            "--ngProbeLocations", project_node_modules,
          }
        end,
      }

      opts.setup = opts.setup or {}
      opts.setup.angularls = function()
        Snacks.util.lsp.on({ name = "angularls" }, function(_, client)
          client.server_capabilities.renameProvider = false
        end)

        -- On .ts files, disable angularls capabilities that conflict with vtsls.
        -- angularls still tracks .ts files internally for template resolution.
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "angularls" then
              local ft = vim.bo[args.buf].filetype
              if ft == "typescript" then
                client.server_capabilities.completionProvider = nil
                client.server_capabilities.hoverProvider = nil
                client.server_capabilities.signatureHelpProvider = nil
                client.server_capabilities.codeActionProvider = nil
              end
            end
          end,
        })
      end
    end,
  },
}
