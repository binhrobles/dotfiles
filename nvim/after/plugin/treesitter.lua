require("nvim-treesitter").install({
  "json",
  "javascript",
  "typescript",
  "tsx",
  "yaml",
  "html",
  "css",
  "markdown",
  "markdown_inline",
  "bash",
  "lua",
  "vim",
  "dockerfile",
  "gitignore",
  "rust",
  "python",
  "gdscript",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", {}),
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
