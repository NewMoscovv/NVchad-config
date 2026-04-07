local M = {}

local excluded_filetypes = {
  NvimTree = true,
  alpha = true,
  checkhealth = true,
  dapui_breakpoints = true,
  dapui_console = true,
  dapui_scopes = true,
  dapui_stacks = true,
  dapui_watches = true,
  help = true,
  lazy = true,
  mason = true,
  notify = true,
  qf = true,
}

local function should_enable(bufnr)
  if vim.bo[bufnr].buftype ~= "" then
    return false
  end

  return not excluded_filetypes[vim.bo[bufnr].filetype]
end

local function filename_for(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return "[No Name]"
  end

  return vim.fn.fnamemodify(name, ":t")
end

function M.render()
  local bufnr = vim.api.nvim_get_current_buf()
  if not should_enable(bufnr) then
    return ""
  end

  local filename = filename_for(bufnr)
  local ok, navic = pcall(require, "nvim-navic")
  if not ok or not navic.is_available() then
    return filename
  end

  local location = navic.get_location()
  if location == "" then
    return filename
  end

  return string.format("%s > %s", filename, location)
end

function M.refresh(winid)
  winid = winid or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(winid) then
    return
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  local value = vim.api.nvim_win_call(winid, M.render)

  if should_enable(bufnr) then
    vim.wo[winid].number = true
    vim.wo[winid].relativenumber = vim.o.relativenumber
  end

  vim.wo[winid].winbar = value
end

function M.setup()
  local navic = require "nvim-navic"

  navic.setup {
    highlight = true,
    lazy_update_context = false,
    separator = " > ",
    depth_limit = 5,
    icons = {},
    lsp = {
      auto_attach = false,
    },
  }

  local group = vim.api.nvim_create_augroup("navic_winbar", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or not client.server_capabilities.documentSymbolProvider then
        return
      end

      navic.attach(client, args.buf)
      M.refresh()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "CursorMoved", "InsertLeave", "WinEnter" }, {
    group = group,
    callback = function(args)
      M.refresh(args.win)
    end,
  })
end

return M
