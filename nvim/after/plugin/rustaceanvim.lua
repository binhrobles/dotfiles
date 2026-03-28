vim.g.rustaceanvim = {
  server = {
    settings = {
      ["rust-analyzer"] = {
        files = {
          watcher = "server",
        },
        check = {
          command = "clippy",
        },
      },
    },
  },
}
