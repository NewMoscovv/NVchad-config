require "nvchad.options"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.pumblend = 10
vim.opt.winblend = 10

vim.api.nvim_set_hl(0, "NvDashAscii", { fg = "#00ff00" })

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "EndOfBuffer",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "WhichKeyFloat",
  "WhichKeyBorder",
  "LazyNormal",
}

local function make_transparent()
  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

make_transparent()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = make_transparent,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.opt_local.winblend = vim.o.winblend
  end,
})

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
