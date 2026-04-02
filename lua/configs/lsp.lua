local nvchad_lsp = require "nvchad.configs.lspconfig"

nvchad_lsp.defaults()

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  capabilities = nvchad_lsp.capabilities,
  on_init = nvchad_lsp.on_init,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      staticcheck = true,
      gofumpt = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})

local goimports_group = vim.api.nvim_create_augroup("go_auto_imports", { clear = true })

local function organize_go_imports(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
  if #clients == 0 then
    return
  end

  local client = clients[1]
  local last_line_nr = vim.api.nvim_buf_line_count(bufnr)
  local last_line = vim.api.nvim_buf_get_lines(bufnr, last_line_nr - 1, last_line_nr, false)[1] or ""
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = {
        line = math.max(last_line_nr - 1, 0),
        character = #last_line,
      },
    },
  }

  params.context = {
    only = { "source.organizeImports" },
    diagnostics = vim.diagnostic.get(bufnr),
  }

  local result = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
  if not result or not result.result then
    return
  end

  for _, action in ipairs(result.result) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end

    if action.command then
      client:exec_cmd(action.command, { bufnr = bufnr })
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = goimports_group,
  pattern = "*.go",
  callback = function(args)
    organize_go_imports(args.buf)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = goimports_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "gopls" then
      return
    end

    vim.keymap.set("n", "<leader>gi", function()
      organize_go_imports(args.buf)
    end, {
      buffer = args.buf,
      desc = "Go organize imports",
    })
  end,
})

vim.lsp.enable "gopls"
