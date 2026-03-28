require('Trouble').setup()

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = "Toggle diagnostics" })
