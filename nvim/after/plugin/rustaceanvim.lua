vim.g.rustaceanvim = {
  -- LSP configuration
  server = {
    on_attach = function(client)
      -- turn off lsp highlighting
      client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}

