return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		-- LazyVim config for treesitter
		indent = { enable = true }, ---@type lazyvim.TSFeat
		highlight = { enable = true }, ---@type lazyvim.TSFeat
		folds = { enable = true }, ---@type lazyvim.TSFeat
		ensure_installed = {
			"bash",
			"c",
			"css",
			"diff",
			"dockerfile",
			"html",
			"javascript",
			"jsdoc",
			"json",
			"jsonc",
			"lua",
			"luadoc",
			"luap",
			"markdown",
			"markdown_inline",
			"printf",
			"python",
			"query",
			"regex",
			"scss",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
		},
	}
}
