-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Import LazyVim base plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Import your custom plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
