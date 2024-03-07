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
  vi-mode
)

# autocompletions for homebrew
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

source $ZSH/oh-my-zsh.sh

# User configuration

alias gs="git status"
alias gp="git pull"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"

## zsh-autosuggest bindkey
bindkey '^f' autosuggest-execute

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

## asdf helpers
## when in doubt...reshim!
export ASDF_INSTALLS=~/.asdf/installs
export ASDF_GOLANG_MOD_VERSION_ENABLED=true
. ~/.asdf/plugins/golang/set-env.zsh # set GOROOT

# put current python version executables into path aka don't hate your past self when you see this
# export PATH=$PATH:~/.local/bin
# export PATH=$PATH:/usr/local/opt/python/libexec/bin

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
