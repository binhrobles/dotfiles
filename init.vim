call plug#begin()
" Linting
Plug 'dense-analysis/ale'

" Syntax highlighting
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

" Other Tools
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
call plug#end()

" tabs
set shiftwidth=2  " operation >> indents 2 columns; << unindents 2 columns
set tabstop=2     " a hard TAB displays as 2 columns
set expandtab     " insert spaces when hitting TABs
set softtabstop=2 " insert/delete 2 spaces when hitting a TAB/BACKSPACE
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

" local vimrc
"" tell nvim that it should look for local config files and run them
set exrc
set secure

"" tell nerdtree to reload config in the local dir whenever changing tabs
let NERDTreeChDirMode=3

" undo highlighted words
:nnoremap <esc> :noh<return><esc>

" Ale configuration
let g:ale_linters = {
\   'go': ['gometalinter', 'gofmt', 'gobuild'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'go': ['gofmt', 'goimports'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\}

"""" ignore deno linter on typescript files by default!
"""" use local .nvimrc to w/
"""" ```
"""" let g:ale_linters = {'typescript': ['deno']}
"""" let g:ale_fixers = {'typescript': ['deno']}
"""" ```
"""" to re-enable

let g:ale_linters_ignore = {
\   'typescript': ['deno'],
\}
let g:ale_fix_on_save = 1

" Airline configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" autorefresh on buffer deletion
autocmd BufDelete * call airline#extensions#tabline#buflist#invalidate()
