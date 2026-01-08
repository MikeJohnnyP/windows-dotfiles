export ZSH="$HOME/.oh-my-zsh"
export LANG=en_US.UTF-8
export EDITOR="nvim"

ZSH_THEME="robbyrussell"

# History config
HISTSIZE=50000                    # size = 50000
SAVEHIST=50000                    # save = 50000
HISTFILE="/zsh/history"           # path
[[ -d "/zsh" ]] || \
    mkdir -p "/zsh"


plugins=(git fzf-tab zsh-syntax-highlighting zsh-autosuggestions)

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080"

source $ZSH/oh-my-zsh.sh

setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CDABLE_VARS
setopt INTERACTIVE_COMMENTS

zstyle ':fzf-tab:*' fzf-flags --color=bg+:#1e1e2e,spinner:#f5e0dc
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-min-height 10

alias vi='nvim'
alias vim='nvim'
alias ll='ls -la'
