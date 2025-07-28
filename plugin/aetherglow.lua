-- AetherGlow auto-loading
-- This file makes :colorscheme aetherglow work without setup()

vim.api.nvim_create_user_command("AetherGlow", function(opts)
  require("aetherglow").setup(opts)
end, {
  nargs = 0,
  desc = "Load AetherGlow theme with default settings"
})