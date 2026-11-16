require('which-key').setup({
  triggers = {
    { "<leader>", mode = "n" },
    { "g", mode = "n" },
    { "[", mode = "n" },
    { "]", mode = "n" },
  },
  win = {
    no_overlap = false,
  },
})

-- fix which-key colors for gruvbox
local function fix_whichkey_colors()
  vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#ebdbb2", default = false })
  vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#8ec07c", default = false })
  vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#3c3836", fg = "#ebdbb2", default = false })
  vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#928374", default = false })
end

fix_whichkey_colors()
vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_whichkey_colors })
