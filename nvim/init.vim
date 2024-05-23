call plug#begin()
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" linting
Plug 'mrcjkb/rustaceanvim'
Plug 'neovim/nvim-lspconfig'

" autocomplete
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" diagnostic buffers
Plug 'nvim-tree/nvim-web-devicons'
Plug 'folke/trouble.nvim'
Plug 'vim-airline/vim-airline'

" auto grep / navigation
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }
Plug 'preservim/nerdtree'

" theming
Plug 'morhetz/gruvbox'

" other stuff
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
call plug#end()

" tabs
set shiftwidth=2  " operation >> indents 2 columns; << unindents 2 columns
set tabstop=2     " a hard TAB displays as 2 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=2 " insert/delete 2 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

" folding
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

" local vimrc
"" tell nvim that it should look for local config files and run them
set exrc
set secure
let mapleader = "\<Space>"

" tell nvim to treat .hbs files like html
au BufRead,BufNewFile *.hbs set filetype=html

"" tell nerdtree to reload config in the local dir whenever changing tabs
let NERDTreeChDirMode=3

" undo highlighted words
nnoremap <esc> :noh<return><esc>

" Trouble diagnostics configuration
nnoremap <leader>xx <cmd>TroubleToggle<cr>

" Tab through autocomplete options
inoremap <silent><expr><TAB>
    \ pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr><S-TAB>
    \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

" Coq autocomplete
let g:coq_settings = { 'auto_start': v:true }

" Airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" autorefresh on buffer deletion
autocmd BufDelete * call airline#extensions#tabline#buflist#invalidate()

" remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX) && getenv('TERM_PROGRAM') != 'Apple_Terminal')
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" activate gruvbox dark colorscheme (alt: light)
" from https://iterm2colorschemes.com/
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark
