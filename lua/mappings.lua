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

local function telescope_git_builtin(picker, missing_msg)
  return function()
    local root = git_root()
    if not root then
      vim.notify(missing_msg, vim.log.levels.WARN)
      return
    end

    require("telescope.builtin")[picker] { cwd = root }
  end
end

map("n", "<leader>gt", telescope_git_builtin("git_status", "Git repo not found for current file"), {
  desc = "telescope git status",
})
map("n", "<leader>cm", telescope_git_builtin("git_commits", "Git repo not found for current file"), {
  desc = "telescope git commits",
})


vim.keymap.set("n", "<leader>h", function()
  vim.cmd("Nvdash")
end, { desc = "Open Dashboard" })



-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
