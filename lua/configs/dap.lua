local dap = require("dap")

-- breakpoint
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })

-- старт / продолжить
vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end, { desc = "Start / Continue Debug" })

-- открыть debug REPL
vim.keymap.set("n", "<leader>dr", function()
  dap.repl.open()
end, { desc = "Open Debug REPL" })

-- включить / выключить UI
vim.keymap.set("n", "<leader>du", function()
  local ok, dapui = pcall(require, "dapui")
  if ok then
    dapui.toggle()
  end
end, { desc = "Toggle Debug UI" })

-- дебаг теста
vim.keymap.set("n", "<leader>dt", function()
  require("dap-go").debug_test()
end, { desc = "Debug Test" })

-- повтор последнего запуска
vim.keymap.set("n", "<leader>dl", function()
  require("dap-go").debug_last()
end, { desc = "Debug Last Run" })

-- breakpoint значок
vim.fn.sign_define("DapBreakpoint", {
  text = "🔴",
  texthl = "DiagnosticError",
})
