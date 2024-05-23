local treesitter = require("nvim-treesitter.configs")

treesitter.setup({
  highlight = {
    enable = false,
  },

  indent = { enable = true },

  ensure_installed = {
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
  },
})
