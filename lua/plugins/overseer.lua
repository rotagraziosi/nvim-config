return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle" },
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Overseer toggle panel" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer run task" },
      {
        "<leader>ob",
        function()
          require("overseer").run_template({ name = "buildwatch" })
        end,
        desc = "Overseer build watch",
      },
      {
        "<leader>ot",
        function()
          require("overseer").run_template({ name = "test" })
        end,
        desc = "Overseer test",
      },
      {
        "<leader>ou",
        function()
          require("overseer").run_template({ name = "unit-test" })
        end,
        desc = "Overseer unit test",
      },
      {
        "<leader>os",
        function()
          require("overseer").run_template({ name = "start" })
        end,
        desc = "Overseer start",
      },
    },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 15,
      },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      overseer.register_template({
        name = "buildwatch",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "run", "buildwatch", "--", "--aot", "--progress" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })

      overseer.register_template({
        name = "test",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "run", "test" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })

      overseer.register_template({
        name = "unit-test",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "run", "unit-test" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })

      overseer.register_template({
        name = "start",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "start" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })
    end,
  },
}
