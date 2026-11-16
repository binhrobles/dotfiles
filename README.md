# dotfiles

zsh (oh-my-zsh), tmux, git, Neovim, Hammerspoon, and a Brewfile for macOS.

## Setup
1. Install [Homebrew](https://brew.sh), then `brew bundle --file=Brewfile`.
2. Install [oh-my-zsh](https://ohmyz.sh). Clone the non-bundled plugins listed in `.zshrc` (`zsh-vi-mode`, `fzf-tab`, `zsh-autosuggestions`, `zsh-syntax-highlighting`) into `~/.oh-my-zsh/custom/plugins/`.
3. Link everything with [rhysd/dotfiles](https://github.com/rhysd/dotfiles) (mappings in `.dotfiles/mappings.json`):
   ```
   dotfiles link
   ```
4. Install [tpm](https://github.com/tmux-plugins/tpm), then `prefix + I` in tmux.
5. Open `nvim`; `vim.pack` installs plugins on first launch (lockfile: `nvim/nvim-pack-lock.json`).

## Language toolchains
Each language uses its own recommended manager:
- Node: [nvm](https://github.com/nvm-sh/nvm); `.nvmrc` files switch versions on `cd`
- Rust: [rustup](https://rustup.rs)
- Python: [uv](https://docs.astral.sh/uv/) (`uv python install <version> --default`)
