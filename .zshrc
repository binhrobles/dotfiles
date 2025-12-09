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
  asdf
  autojump
  aws
  git
  zsh-vi-mode
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# autocompletions for homebrew
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

### zsh
source $ZSH/oh-my-zsh.sh

### Radar-specific stuff
source ~/.radar.zshrc

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
alias llama="llama-server --fim-qwen-3b-default --port 8012 -ngl 99 -fa -ub 1024 -b 1024 -dt 0.1 --ctx-size 0 --cache-reuse 256"
# alias llama="llama-server -hf ggml-org/Qwen2.5-Coder-3B-Q8_0-GGUF --port 8012 -ngl 99 -fa -ub 1024 -b 1024 -dt 0.1 --ctx-size 0 --cache-reuse 256"

## zsh-autosuggest bindkey
bindkey '^f' autosuggest-execute

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

## asdf helpers
### when in doubt...reshim!
export ASDF_INSTALLS=~/.asdf/installs

### yarn binaries
export PATH="$PATH:$(yarn global bin)"

### Go
export ASDF_GOLANG_MOD_VERSION_ENABLED=true
. ~/.asdf/plugins/golang/set-env.zsh # set GOROOT

# Created by `pipx` on 2024-03-07 22:35:38
export PATH="$PATH:~/.local/bin"

# For cargo compiled binaries
export PATH="$PATH:$HOME/.cargo/bin"

# For SQLite
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# scala
export PATH="$PATH:/Users/binh.robles/Library/Application Support/Coursier/bin"
export PATH="$HOME/.local/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/binh.robles/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
