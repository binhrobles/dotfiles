vim.g.rustaceanvim = {
  server = {
    settings = {
      ["rust-analyzer"] = {
        -- rustaceanvim defaults to "server", which took ~35s vs ~9s to first hover in geocoder/api
        files = {
          watcher = "client",
        },
        check = {
          command = "clippy",
        },
      },
    },
  },
}
