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
      {
        "<leader>oi",
        function()
          require("overseer").run_template({ name = "install" })
        end,
        desc = "Overseer install",
      },
      {
        "<leader>odcu",
        function()
          require("overseer").run_template({ name = "Docker compose up" })
        end,
        desc = "Overseer docker compose up",
      },
      {
        "<leader>odcd",
        function()
          require("overseer").run_template({ name = "Docker compose down" })
        end,
        desc = "Overseer docker compose down",
      },
      {
        "<leader>odcw",
        function()
          require("overseer").run_template({ name = "Docker compose watch" })
        end,
        desc = "Overseer docker compose watch",
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

      -- ── Jump to the file under the cursor from a task's output window ──────
      -- Handles tokens like:
      --   src/app/foo.component.ts:12:5      (tsc / webpack)
      --   src/app/foo.component.ts:12:5:     (esbuild / Angular application builder)
      --   src/app/foo.component.ts(12,5)     (some formatters)
      --   src/app/foo.component.ts:12
      local function open_from_output()
        local word = vim.fn.expand("<cWORD>")
        word = word:gsub("^[%(%[\"']+", ""):gsub("[%)%],:\"']+$", "")

        local file, lnum, col = word:match("^(.-):(%d+):(%d+)$")
        if not file then
          file, lnum, col = word:match("^(.-)%((%d+),(%d+)%)$")
        end
        if not file then
          file, lnum = word:match("^(.-):(%d+)$")
        end
        if not file or file == "" then
          vim.notify("Overseer: no file:line in <" .. word .. ">", vim.log.levels.WARN)
          return
        end

        -- resolve relative paths against the task's cwd when we can find it
        local dir = vim.fn.getcwd()
        local cur_buf = vim.api.nvim_get_current_buf()
        for _, task in ipairs(overseer.list_tasks({})) do
          if task.get_bufnr and task:get_bufnr() == cur_buf then
            dir = task.cwd or dir
            break
          end
        end

        local path = file
        if not (path:match("^%a:[/\\]") or path:match("^[/\\]")) then
          path = dir .. "/" .. file
        end
        path = vim.fs.normalize(path)
        if vim.fn.filereadable(path) == 0 then
          local alt = vim.fs.normalize(vim.fn.getcwd() .. "/" .. file)
          if vim.fn.filereadable(alt) == 1 then
            path = alt
          end
        end

        -- leave the output window before opening the file
        local from = vim.api.nvim_get_current_win()
        vim.cmd("wincmd p")
        if vim.api.nvim_get_current_win() == from then
          vim.cmd("wincmd k")
        end
        if vim.api.nvim_get_current_win() == from then
          vim.cmd("botright vsplit")
        end

        vim.cmd.edit(vim.fn.fnameescape(path))
        pcall(vim.api.nvim_win_set_cursor, 0, { tonumber(lnum) or 1, math.max((tonumber(col) or 1) - 1, 0) })
        vim.cmd("normal! zz")
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "TermOpen" }, {
        group = vim.api.nvim_create_augroup("overseer_open_from_output", { clear = true }),
        callback = function(args)
          for _, task in ipairs(overseer.list_tasks({})) do
            if task.get_bufnr and task:get_bufnr() == args.buf then
              local km = { buffer = args.buf, silent = true, desc = "Overseer: open file under cursor" }
              vim.keymap.set("n", "gf", open_from_output, km)
              vim.keymap.set("n", "gF", open_from_output, km)
              return
            end
          end
        end,
      })

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

      overseer.register_template({
        name = "install",
        builder = function()
          return {
            cmd = { "npm" },
            args = { "install" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })

      overseer.register_template({
        name = "Docker compose up",
        builder = function()
          return {
            cmd = { "docker" },
            args = { "compose", "up" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })

      overseer.register_template({
        name = "Docker compose down",
        builder = function()
          return {
            cmd = { "docker" },
            args = { "compose", "down" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })

      overseer.register_template({
        name = "Docker compose watch",
        builder = function()
          return {
            cmd = { "docker" },
            args = { "compose", "watch" },
            components = { "default", "on_output_quickfix", { "on_complete_notify", statuses = { "FAILURE" } } },
          }
        end,
      })
    end,
  },
}
