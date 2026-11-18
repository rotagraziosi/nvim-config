-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>tg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>tb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>th", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>tsw", builtin.grep_string, { desc = "Telescope grep word under cursord" })

-- Angular terminal at project root (for ng generate commands)
vim.keymap.set("n", "<leader>ng", function()
  local root = vim.fs.root(0, { "angular.json", "nx.json" }) or vim.fn.getcwd()
  Snacks.terminal(nil, { cwd = root })
end, { desc = "Terminal at Angular project root" })

-- Quickfix navigation (for Overseer build/test error jumping)
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix error" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix error" })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix list" })

--Moving lines
vim.keymap.set("n", "<A-j>", ":m +1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Merge conflicts (git mergetool / nvimdiff, or fugitive :Gvdiffsplit!): take the hunk from LOCAL or REMOTE
-- <leader>gl keeps LazyVim's "Git Log" outside diff mode
-- Buffers are found by git's temp names (file_LOCAL_1234.ext) or fugitive's stages
-- (fugitive://...//2/ = ours, //3/ = theirs): ":diffget LO" is ambiguous when the
-- path contains e.g. "AppData\Local"
local function diffget(side)
  local stage = side == "LOCAL" and "//2/" or "//3/"
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf):gsub("\\", "/")
    local is_side = vim.fs.basename(name):find("_" .. side .. "_", 1, true)
      or (name:find("^fugitive://") and name:find(stage, 1, true))
    if vim.wo[win].diff and buf ~= vim.api.nvim_get_current_buf() and is_side then
      -- Inside a <<<<<<< ... >>>>>>> block, take the whole block (the markers split it into several hunks)
      local first = vim.fn.search("^<<<<<<<", "bcnW")
      local last = vim.fn.search("^>>>>>>>", "cnW")
      local in_conflict = first > 0 and last > 0 and vim.fn.search("^>>>>>>>", "bnW") < first
      vim.cmd((in_conflict and (first .. "," .. last) or "") .. "diffget " .. buf)
      return
    end
  end
  vim.notify("No " .. side .. " buffer in this diff", vim.log.levels.WARN)
end

-- From a git_log picker item: pick one of the commit's files and open it, as it was
-- in that commit, in the current window (read-only fugitive buffer)
local function commit_files(picker, item)
  if not item or not item.commit then
    return
  end
  local commit, cwd = item.commit, item.cwd
  -- --root: first commit has no parent; -m --first-parent: merges list their changes too
  local res = vim
    .system(
      { "git", "diff-tree", "-r", "--root", "-m", "--first-parent", "--no-commit-id", "--name-only", commit },
      { cwd = cwd }
    )
    :wait()
  local items = {}
  for _, path in ipairs(vim.split(vim.trim(res.stdout or ""), "\n", { trimempty = true })) do
    items[#items + 1] = { text = path, file = path, cwd = cwd }
  end
  if #items == 0 then
    vim.notify("No files in " .. commit, vim.log.levels.WARN)
    return
  end
  picker:close()
  Snacks.picker.pick({
    title = commit .. " " .. (item.msg or ""),
    items = items,
    format = "file",
    preview = function(ctx)
      local ft = vim.filetype.match({ filename = ctx.item.file })
      return Snacks.picker.preview.cmd({ "git", "show", commit .. ":" .. ctx.item.file }, ctx, { ft = ft or "text" })
    end,
    confirm = function(p, file)
      p:close()
      if not file then
        return
      end
      require("lazy").load({ plugins = { "vim-fugitive" } })
      local url = vim.fn.FugitiveFind(commit .. ":" .. file.file, vim.fn.FugitiveExtractGitDir(cwd))
      vim.cmd.edit(vim.fn.fnameescape(url))
    end,
  })
end

vim.keymap.set("n", "<leader>gl", function()
  if vim.wo.diff then
    diffget("LOCAL")
  else
    Snacks.picker.git_log({
      cwd = LazyVim.root.git(),
      actions = { commit_files = commit_files },
      win = {
        input = { keys = { ["<c-o>"] = { "commit_files", mode = { "n", "i" }, desc = "Open a file of this commit" } } },
        list = { keys = { ["<c-o>"] = { "commit_files", desc = "Open a file of this commit" } } },
      },
    })
  end
end, { desc = "Diffget LOCAL (diff) / Git Log (<c-o>: open a file of the commit)" })

vim.keymap.set("n", "<leader>gr", function()
  if vim.wo.diff then
    diffget("REMOTE")
  else
    vim.notify("Not in diff mode", vim.log.levels.WARN)
  end
end, { desc = "Diffget REMOTE (diff)" })

-- Merge layout for the conflicted file: LOCAL (//2) | REMOTE (//3) on top, MERGED below
vim.keymap.set("n", "<leader>gm", function()
  -- Stages 2/3 only exist while the file is unmerged (gone after :Gwrite / git add)
  local file = vim.api.nvim_buf_get_name(0)
  local stages = vim.system({ "git", "ls-files", "-u", "--", file }, { cwd = vim.fs.dirname(file) }):wait().stdout or ""
  if not (stages:find("%s2%s") and stages:find("%s3%s")) then
    vim.notify(
      "No LOCAL/REMOTE stages: file is not in conflict (already staged?).\n"
        .. ":Git checkout -m % recreates the conflict (drops your edits)",
      vim.log.levels.WARN
    )
    return
  end
  vim.cmd("only")
  vim.cmd("aboveleft split | Gedit :2:%")
  vim.cmd("rightbelow vsplit | Gedit :3:%")
  -- diffthis once all windows exist: fugitive turns diff off on the //2 window when //3 opens
  vim.cmd("windo diffthis")
  vim.cmd("wincmd b")
end, { desc = "Merge layout (LOCAL | REMOTE / MERGED)" })

-- Sirius translation
local function translations_dir()
  local root = vim.fs.root(0, { "angular.json" }) or vim.fn.getcwd()
  return vim.fs.normalize(root .. "/../Resources/Translations")
end

vim.keymap.set("n", "<leader>tr", function()
  builtin.find_files({ cwd = translations_dir() })
end, { desc = "Translation files" })

vim.keymap.set("n", "<leader>tR", function()
  builtin.live_grep({ cwd = translations_dir(), glob_pattern = "translate_*.json" })
end, { desc = "Grep translations" })

-- Cursor on 'PLANNING.TOOLBAR.TITLE' | translate → show it in every language
vim.keymap.set("n", "<leader>tk", function()
  builtin.grep_string({ cwd = translations_dir(), search = vim.fn.expand("<cfile>") })
end, { desc = "Translation key under cursor" })

-- Angular specific keymapping
local targets = {
  ts = { ".ts" },
  html = { ".html" },
  style = { ".scss", ".css", ".sass", ".less" },
  spec = { ".spec.ts" },
}

local function angular_switch(kind)
  local file = vim.api.nvim_buf_get_name(0)
  -- strip ".spec.ts" first, then any single extension
  local base = (file:gsub("%.spec%.ts$", ""))
  base = (base:gsub("%.[^./]+$", ""))

  for _, ext in ipairs(targets[kind]) do
    local candidate = base .. ext
    if candidate ~= file and vim.fn.filereadable(candidate) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(candidate))
      return
    end
  end
  vim.notify("No " .. kind .. " file found for " .. vim.fn.fnamemodify(base, ":t"), vim.log.levels.WARN)
end

vim.keymap.set("n", "<leader>ac", function()
  angular_switch("ts")
end, { desc = "Angular: component (.ts)" })
vim.keymap.set("n", "<leader>at", function()
  angular_switch("html")
end, { desc = "Angular: template (.html)" })
vim.keymap.set("n", "<leader>as", function()
  angular_switch("style")
end, { desc = "Angular: style" })
vim.keymap.set("n", "<leader>aS", function()
  angular_switch("spec")
end, { desc = "Angular: spec" })
