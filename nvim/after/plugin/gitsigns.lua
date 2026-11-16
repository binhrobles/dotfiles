require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')

    local function opts(desc)
      return { buffer = bufnr, desc = desc }
    end

    vim.keymap.set('n', ']c', function() gs.nav_hunk('next') end, opts("Next git hunk"))
    vim.keymap.set('n', '[c', function() gs.nav_hunk('prev') end, opts("Prev git hunk"))
    vim.keymap.set('n', '<leader>hs', gs.stage_hunk, opts("Stage hunk"))
    vim.keymap.set('n', '<leader>hr', gs.reset_hunk, opts("Reset hunk"))
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, opts("Preview hunk"))
    vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, opts("Blame line"))
  end,
})
