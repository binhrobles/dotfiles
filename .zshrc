# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="~/.oh-my-zsh"

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
	git
	vi-mode
	zsh-syntax-highlighting
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

alias gs="git status"
alias gp="git pull"
alias gd="git diff"
alias ga="git add"
alias gc="git commit"

alias awslocal="aws --endpoint-url=http://localhost:4566"

## zsh-autosuggest bindkey
bindkey '^f' autosuggest-execute

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# The next line updates PATH for the Google Cloud SDK.
if [ -f '~/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '~/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '~/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '~/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

## asdf helpers
export ASDF_INSTALLS=~/.asdf/installs
alias go-reshim='asdf reshim golang && \
                 export GOV=$(asdf current golang | sed  '\''s/ *(set by .*)//g'\'') && \
                 export GOROOT="$ASDF_INSTALLS/golang/$GOV/go" && \
                 export GOBIN="$GOROOT/bin" && \
                 export PATH=$GOBIN:$PATH'

# put current python version executables into path aka don't hate your past self when you see this
export PATH=$PATH:~/.local/bin
export PATH=$PATH:/usr/local/opt/python/libexec/bin

# put yarn execs in path
export PATH=$PATH:$(yarn global bin)

# eb util
export PATH="~/.ebcli-virtual-env/executables:$PATH"
