vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Diagnostic float" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })

-- let treesitter handle all syntax highlighting
vim.lsp.semantic_tokens.enable(false)

local format_on_save = {
  eslint = true,
  cssls = true,
  jsonls = true,
  metals = true,
  ['typescript-tools'] = true,
}

local function format_group(bufnr, client_id)
  return ('UserLspFormat.%d.%d'):format(bufnr, client_id)
end

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
local group = vim.api.nvim_create_augroup('UserLspConfig', {})
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local function buf_opts(desc)
      return { buffer = ev.buf, desc = desc }
    end
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, buf_opts("Go to declaration"))
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, buf_opts("Go to definition"))
    vim.keymap.set('n', 'g?', vim.diagnostic.open_float, buf_opts("Diagnostic float"))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, buf_opts("Go to implementation"))
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, buf_opts("Type definition"))
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, buf_opts("Rename symbol"))
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, buf_opts("Code action"))
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, buf_opts("Find references"))
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, buf_opts("Format buffer"))

    if client:supports_method('textDocument/inlayHint', ev.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    if format_on_save[client.name] then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup(format_group(ev.buf, client.id), {}),
        buffer = ev.buf,
        callback = function(args)
          if client:supports_method('textDocument/formatting', args.buf) then
            vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
          end
        end,
      })
    end
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = group,
  callback = function(ev)
    pcall(vim.api.nvim_del_augroup_by_name, format_group(ev.buf, ev.data.client_id))
  end,
})

-- JS/TS uses typescript-tools.nvim instead of ts_ls
vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  },
})

-- vim.lsp.enable({ 'pyright', 'markdown_oxide' })

-- metals: requires coursier, java, metals lsp installed
vim.lsp.enable({ 'eslint', 'cssls', 'jsonls', 'html', 'lua_ls', 'metals' })
