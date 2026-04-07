require "nvchad.options"

local colors = require("base46").get_theme_tb "base_30"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.pumblend = 6
vim.opt.winblend = 6

vim.api.nvim_set_hl(0, "NvDashAscii", { fg = "#00ff00" })

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "EndOfBuffer",
  "WinBar",
  "WinBarNC",
  "TelescopeNormal",
  "TelescopeBorder",
  "TelescopePromptNormal",
  "TelescopePromptBorder",
  "WhichKeyFloat",
  "WhichKeyBorder",
  "LazyNormal",
}

local transparent_markdown_groups = {
  "RenderMarkdownCode",
  "RenderMarkdownCodeInline",
  "RenderMarkdownCodeInfo",
  "RenderMarkdownCodeFallback",
}

local transparent_snacks_groups = {
  "SnacksBackdrop",
  "SnacksNormal",
  "SnacksBorder",
  "SnacksTitle",
  "SnacksFooter",
  "SnacksPickerNormalFloat",
  "SnacksPickerBorder",
  "SnacksPickerTitle",
  "SnacksPickerFooter",
  "SnacksPickerInputNormalFloat",
  "SnacksPickerInputBorder",
  "SnacksPickerInputTitle",
  "SnacksPickerInputFooter",
  "SnacksPickerListNormalFloat",
  "SnacksPickerListBorder",
  "SnacksPickerListTitle",
  "SnacksPickerListFooter",
  "SnacksPickerPreviewNormalFloat",
  "SnacksPickerPreviewBorder",
  "SnacksPickerPreviewTitle",
  "SnacksPickerPreviewFooter",
  "SnacksPickerBoxNormalFloat",
  "SnacksPickerBoxBorder",
  "SnacksPickerBoxTitle",
  "SnacksPickerBoxFooter",
}

local surface_groups = {
  NormalFloat = { bg = colors.darker_black },
  FloatBorder = { bg = colors.darker_black },
  NvimTreeNormal = { bg = colors.darker_black },
  NvimTreeNormalNC = { bg = colors.darker_black },
  NvimTreeNormalFloat = { bg = colors.darker_black },
  NvimTreeNormalFloatBorder = { bg = colors.darker_black },
  NvimTreeEndOfBuffer = { bg = colors.darker_black },
  NvimTreeWinSeparator = { bg = colors.darker_black },
}

local function set_hl(group, opts)
  local ok, current = pcall(vim.api.nvim_get_hl, 0, { name = group })
  local merged = ok and vim.tbl_extend("force", current, opts) or opts
  vim.api.nvim_set_hl(0, group, merged)
end

local function make_transparent()
  for _, group in ipairs(transparent_groups) do
    set_hl(group, { bg = "NONE" })
  end

  for _, group in ipairs(transparent_markdown_groups) do
    set_hl(group, { bg = "NONE" })
  end

  for _, group in ipairs(transparent_snacks_groups) do
    set_hl(group, { bg = "NONE" })
  end

  for group, opts in pairs(surface_groups) do
    set_hl(group, opts)
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
