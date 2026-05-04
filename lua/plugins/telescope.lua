local ts_select_dir_for_grep = function(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local fb = require("telescope").extensions.file_browser
  local live_grep = require("telescope.builtin").live_grep
  local current_line = action_state.get_current_line()

  fb.file_browser({
    files = false,
    depth = false,
    attach_mappings = function(prompt_bufnr)
      require("telescope.actions").select_default:replace(function()
        local entry_path = action_state.get_selected_entry().Path
        local dir = entry_path:is_dir() and entry_path or entry_path:parent()
        local relative = dir:make_relative(vim.fn.getcwd())
        local absolute = dir:absolute()

        live_grep({
          results_title = relative .. "/",
          cwd = absolute,
          default_text = current_line,
        })
      end)

      return true
    end,
  })
end
return {
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install",
      },
    },
    opts = function(_, opts)
      if not LazyVim.has("flash.nvim") then
        return
      end
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = { n = { s = flash }, i = { ["<c-s>"] = flash } },
      })
      opts.pickers = {
        live_grep = {
          mappings = {
            i = {
              ["<C-f>"] = ts_select_dir_for_grep,
            },
            n = {
              ["<C-f>"] = ts_select_dir_for_grep,
            },
          },
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
  },
}
