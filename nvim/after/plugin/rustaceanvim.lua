vim.g.rustaceanvim = {
  server = {
    -- Newer than the default toolchain's (1.90, matches prod), and still supports it; latest
    -- releases require >= 1.94. Direct path, not `rustup run`, so cargo keeps the default toolchain.
    cmd = { vim.fn.expand("~/.rustup/toolchains/1.94-aarch64-apple-darwin/bin/rust-analyzer") },
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
