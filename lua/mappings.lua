require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "fd", "<ESC>", { desc = "Exit insert mode" })

local function git_root()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local start_dir = buf_path ~= "" and vim.fs.dirname(buf_path) or vim.uv.cwd()
  local git_dir = vim.fs.find(".git", { path = start_dir, upward = true })[1]

  if git_dir then
    return vim.fs.dirname(git_dir)
  end
end

local function snacks_picker(picker, opts)
  return function()
    local resolved_opts = type(opts) == "function" and opts() or opts
    require("snacks").picker[picker](resolved_opts or {})
  end
end

local function snacks_git_picker(picker, missing_msg)
  return function()
    local root = git_root()
    if not root then
      vim.notify(missing_msg, vim.log.levels.WARN)
      return
    end

    require("snacks").picker[picker] { cwd = root }
  end
end

map("n", "<leader>fw", snacks_picker("grep"), {
  desc = "picker live grep",
})
map("n", "<leader>fb", snacks_picker("buffers"), {
  desc = "picker find buffers",
})
map("n", "<leader>fh", snacks_picker("help"), {
  desc = "picker help page",
})
map("n", "<leader>ma", snacks_picker("marks"), {
  desc = "picker find marks",
})
map("n", "<leader>fo", snacks_picker("recent"), {
  desc = "picker find oldfiles",
})
map("n", "<leader>fz", snacks_picker("lines"), {
  desc = "picker find in current buffer",
})
map("n", "<leader>cm", snacks_git_picker("git_log", "Git repo not found for current file"), {
  desc = "picker git commits",
})
map("n", "<leader>gt", snacks_git_picker("git_status", "Git repo not found for current file"), {
  desc = "picker git status",
})
map("n", "<leader>pt", snacks_picker("buffers", { hidden = true, unloaded = true }), {
  desc = "picker buffers",
})
map("n", "<leader>ff", snacks_picker("files"), {
  desc = "picker find files",
})
map("n", "<leader>fa", snacks_picker("files", {
  hidden = true,
  ignored = true,
  follow = true,
}), {
  desc = "picker find all files",
})


vim.keymap.set("n", "<leader>h", function()
  vim.cmd("Nvdash")
end, { desc = "Open Dashboard" })



-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
