vim.g.mapleader = ' '

-- build steps; must exist before vim.pack.add() to run on install
local builds = {
  ['vim-prettier'] = { { 'yarn', 'install', '--frozen-lockfile', '--production' } },
  LuaSnip = { { 'make', 'install_jsregexp' } },
  ['telescope-fzf-native.nvim'] = {
    { 'cmake', '-S.', '-Bbuild', '-DCMAKE_BUILD_TYPE=Release' },
    { 'cmake', '--build', 'build', '--config', 'Release' },
    { 'cmake', '--install', 'build', '--prefix', 'build' },
  },
}

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
    if kind ~= 'install' and kind ~= 'update' then
      return
    end
    if name == 'nvim-treesitter' then
      -- "install" fires before the plugin is on 'runtimepath'
      if not ev.data.active then
        vim.opt.runtimepath:prepend(path)
      end
      require('nvim-treesitter').update():wait(300000)
      return
    end
    for _, cmd in ipairs(builds[name] or {}) do
      local res = vim.system(cmd, { cwd = path }):wait()
      if res.code ~= 0 then
        vim.notify(('%s build failed: %s\n%s'):format(name, table.concat(cmd, ' '), res.stderr), vim.log.levels.ERROR)
        return
      end
    end
  end,
})

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add({
  -- code tooling
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  gh('nvim-treesitter/nvim-treesitter-context'),
  -- server definitions (lsp/*.lua) for vim.lsp.config
  gh('neovim/nvim-lspconfig'),

  -- linting
  gh('prettier/vim-prettier'),
  gh('mechatroner/rainbow_csv'),

  -- autocomplete
  gh('hrsh7th/nvim-cmp'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-nvim-lsp-signature-help'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-path'),
  { src = gh('L3MON4D3/LuaSnip'), version = 'v2.3.0' },

  -- diagnostic buffers
  gh('nvim-tree/nvim-web-devicons'),
  gh('vim-airline/vim-airline'),
  gh('folke/trouble.nvim'),

  -- auto grep / navigation
  gh('nvim-lua/plenary.nvim'),
  gh('ruifm/gitlinker.nvim'),
  gh('nvim-telescope/telescope-fzf-native.nvim'),
  gh('nvim-telescope/telescope.nvim'),
  gh('preservim/nerdtree'),

  -- language specific
  gh('mrcjkb/rustaceanvim'),
  gh('pmizio/typescript-tools.nvim'),
  gh('evanleck/vim-svelte'),

  -- theming
  gh('morhetz/gruvbox'),
  gh('scottmckendry/cyberdream.nvim'),
  gh('zaldih/themery.nvim'),

  -- git
  gh('sindrets/diffview.nvim'),
  gh('lewis6991/gitsigns.nvim'),

  -- markdown
  gh('MeanderingProgrammer/render-markdown.nvim'),

  -- other stuff
  gh('tpope/vim-commentary'),
  gh('tpope/vim-surround'),
  gh('tpope/vim-repeat'),
  gh('windwp/nvim-autopairs'),
  gh('folke/which-key.nvim'),
})

-- tabs
vim.o.shiftwidth = 2 -- operation >> indents 2 columns; << unindents 2 columns
vim.o.tabstop = 2 -- a hard TAB displays as 2 columns
vim.o.expandtab = true -- insert spaces when hitting TABs
vim.o.softtabstop = 2 -- insert/delete 2 spaces when hitting a TAB/BACKSPACE
vim.o.shiftround = true -- round indent to multiple of 'shiftwidth'
vim.o.autoindent = true -- align the new line indent with the previous line

-- line numbers
-- vim.o.relativenumber = true
vim.o.number = true
vim.o.relativenumber = false

-- folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldenable = false

-- local vimrc
-- tell nvim that it should look for local config files and run them
vim.o.exrc = true
vim.o.secure = true

vim.o.termguicolors = true

-- tell nvim to treat .hbs files like html
vim.filetype.add({ extension = { hbs = 'html' } })

-- tell nerdtree to reload config in the local dir whenever changing tabs
vim.g.NERDTreeChDirMode = 3

-- undo highlighted words
vim.keymap.set('n', '<Esc>', ':noh<CR><Esc>')

vim.keymap.set('n', '<Tab>', ':bn<CR>')
vim.keymap.set('n', '<S-Tab>', ':bp<CR>')

-- Airline configuration
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#tabline#left_sep'] = ' '
vim.g['airline#extensions#tabline#left_alt_sep'] = '|'

local group = vim.api.nvim_create_augroup('init', {})

-- autorefresh on buffer deletion
vim.api.nvim_create_autocmd('BufDelete', {
  group = group,
  command = 'call airline#extensions#tabline#buflist#invalidate()',
})

-- remove trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  callback = function(ev)
    if not vim.bo[ev.buf].modifiable then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- activate gruvbox dark colorscheme (alt: light)
-- from https://iterm2colorschemes.com/
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  nested = true,
  command = 'colorscheme gruvbox',
})

--------------- radar-specific config ---------------

-- set acceptance tests to default to pipe separated files
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  group = group,
  pattern = {
    '~/code/radar/data/geocoder/api/acceptance/**/*.csv',
    '~/code/radar/data-swp/geocoder/api/acceptance/**/*.csv',
  },
  command = 'set filetype=csv_pipe',
})
