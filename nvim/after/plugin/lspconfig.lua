vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'g?', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

local status, lspconfig = pcall(require, "lspconfig")
if (not status) then return end

-- lspconfig.pyright.setup {}
-- lspconfig.markdown_oxide.setup {}

local on_attach = function(client, bufnr)
  vim.lsp.inlay_hint.enable(true)

  -- let treesitter handle all syntax highlighting
  -- turn off lsp highlighting
  client.server_capabilities.semanticTokensProvider = nil

  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("Format", { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end
    })
  end
end

local on_attach_without_inlay_hints = function(client, bufnr)
  vim.lsp.inlay_hint.enable(false)

  -- let treesitter handle all syntax highlighting
  -- turn off lsp highlighting
  client.server_capabilities.semanticTokensProvider = nil

  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("Format", { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end
    })
  end
end



-- JS/TS setup

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- servers without inlay hints
lspconfig['ts_ls'].setup {
  on_attach = function(client, bufnr)
    vim.lsp.inlay_hint.enable(false)

    -- let treesitter handle all syntax highlighting
    -- turn off lsp highlighting
    client.server_capabilities.semanticTokensProvider = nil

    -- format on save
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("Format", { clear = true }),
        buffer = bufnr,
        callback = function() vim.lsp.buf.format() end
      })
    end
  end,
  settings = {
    typescript = {
      inlayHints = {
        interactiveInlayHints = false, -- Disable interactive inlay hints
      }
    },
    javascript = {
      inlayHints = {
        interactiveInlayHints = false, -- Disable interactive inlay hints
      }
    }
  }
  -- capabilities = capabilities
}

local servers = { 'eslint' }
for _, lsp in pairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach_without_inlay_hints
    -- capabilities = capabilities
  })
end

-- metals: requires coursier, java, metals lsp installed
local servers = { 'cssls', 'jsonls', 'metals' }
for _, lsp in pairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach
    -- capabilities = capabilities
  })
end
