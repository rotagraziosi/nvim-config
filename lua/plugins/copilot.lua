return {
  -- Disable copilot.vim (replaced by copilot.lua for blink.cmp integration)
  { "github/copilot.vim", enabled = false },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false }, -- handled by blink-copilot
      panel = { enabled = false },
    },
    enabled = false,
  },
}
