# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  autojump
  aws
  git
  zsh-vi-mode
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
)

typeset -U path fpath

# autocompletions for homebrew
fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

### zsh
source $ZSH/oh-my-zsh.sh

### Radar-specific stuff
source ~/.radar.zshrc
export EDITOR=/opt/homebrew/bin/nvim

# User configuration
fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --bind=tab:up,btab:down \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

fzf-git-checkout() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

# monkey patch in zsh vim yank
function zvm_vi_yank() {
	zvm_yank
	echo ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}

alias gb="fzf-git-branch"
alias fco="fzf-git-checkout"
alias gs="git status"
alias gp="git pull"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"
alias takeover="tmux detach -a"

# start llama server for nvim code completion
alias llama="llama-server -hf ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF --port 8012 -ngl 99 -fa -ub 1024 -b 1024 -dt 0.1 --ctx-size 0 --cache-reuse 256"

## zsh-autosuggest bindkey
bindkey '^f' autosuggest-execute

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# `yarn global bin`, hardcoded: the subshell costs ~250ms per shell
path+=("$HOME/.yarn/bin")

# pipx / uv tools and uv's default python
path=("$HOME/.local/bin" $path)

# For SQLite
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --no-use skips nvm's ~500ms default resolution; put the default node on PATH directly
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh" --no-use
  nvm_default_bin="$NVM_DIR/versions/node/v${$(<"$NVM_DIR/alias/default")#v}/bin"
  if [ -d "$nvm_default_bin" ]; then
    path=("$nvm_default_bin" $path)
  else
    nvm use default --silent # alias is not a concrete version (e.g. lts/*)
  fi
  unset nvm_default_bin
fi
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# place this after nvm initialization!
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
   local nvmrc_node_version
   nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

   if [ "$nvmrc_node_version" = "N/A" ]; then
    nvm install
   elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
    nvm use
   fi
   elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
   fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
