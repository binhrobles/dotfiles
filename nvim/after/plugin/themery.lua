require("themery").setup({
  themes = {{
    name = "Gruvbox Dark",
    colorscheme = "gruvbox",
    before = [[
      -- All this block will be executed before apply "set colorscheme"
      vim.opt.background = "dark"
      vim.g.gruvbox_italic = 1
    ]],
    -- after = [[-- Same as before, but after if you need it]]
  },
  {
    name = "Gruvbox Light -- High Contrast",
    colorscheme = "gruvbox",
    before = [[
      vim.opt.background = "light"
      vim.g.gruvbox_italic = 1
      vim.g.gruvbox_contrast_light = "hard"
    ]],
  },
  {
    name = "Gruvbox Light -- Low Contrast",
    colorscheme = "gruvbox",
    before = [[
      vim.opt.background = "light"
      vim.g.gruvbox_italic = 1
      vim.g.gruvbox_contrast_light = "soft"
    ]],
  },
  {
    name = "CyberDream Dark",
    colorscheme = "cyberdream",
    before = [[
      vim.opt.background = "dark"
    ]],
  },
  {
    name = "CyberDream Light",
    colorscheme = "cyberdream",
    before = [[
      vim.opt.background = "light"
    ]],
  }},
})

