return {
	-- Mason for managing LSP servers
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		keys = {
			{ "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
		},
		opts = {
			ensure_installed = {
				"typescript-language-server",
				"angular-language-server",
				"html-lsp",
				"css-lsp",
				"eslint-lsp",
				"prettier",
			},
		},
		config = function(_, opts)
			require("mason").setup()
			local mr = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"ts_ls",
				"angularls",
				"html",
				"cssls",
				"eslint",
			},
		},
	},
	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			-- Only require cmp_nvim_lsp if cmp is loaded
			local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			if cmp_nvim_lsp_ok then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			local lspconfig = require("lspconfig")

			-- LSP keymaps
			local on_attach = function(client, bufnr)
				local opts = { buffer = bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<leader>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
				vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end

			-- TypeScript/JavaScript Language Server (for Angular)
			lspconfig.ts_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				init_options = {
					preferences = {
						importModuleSpecifierPreference = "relative",
						importModuleSpecifierEnding = "minimal",
					},
				},
			})

			-- Angular Language Server
			local ngserver_cmd = vim.fn.has("win32") == 1
					and { "cmd.exe", "/C", "ngserver", "--stdio", "--tsProbeLocations", ".", "--ngProbeLocations", "." }
				or { "ngserver", "--stdio", "--tsProbeLocations", ".", "--ngProbeLocations", "." }

			lspconfig.angularls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				cmd = ngserver_cmd,
				on_new_config = function(new_config, new_root_dir)
					new_config.cmd = ngserver_cmd
				end,
				filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
			})

			-- HTML Language Server (for Angular templates)
			lspconfig.html.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "html" },
			})

			-- CSS/SCSS Language Server (for Angular styles)
			lspconfig.cssls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "css", "scss", "less" },
			})

			-- ESLint Language Server
			lspconfig.eslint.setup({
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
				capabilities = capabilities,
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
			})

			-- Diagnostic configuration
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			-- Diagnostic signs
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			-- LSP handlers
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})

			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
			})
		end,
	},
}
