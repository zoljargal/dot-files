
# history 
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=1000

autoload -U colors && colors
autoload -U bashcomp
autoload -U compinit && compinit
autoload -U run-help
autoload -Uz add-zsh-hook vcs_info

add-zsh-hook precmd vcs_info
setopt prompt_subst

bindkey -e

setopt autocd extendedglob prompt_subst
setopt appendhistory share_history histignorealldups

# default apps
(( ${+PAGER} )) || export PAGER="less"

# propmt
precmd() {
	vcs_info
}

zstyle ':vcs_info:*' formats "%b"

local return_code="%(?..%{$fg[red]%})"

NEWLINE=$'\n'
RPROMPT='${vcs_info_msg_0_}'
PROMPT='%F{magenta}$(__kube_ps2)%f@%F{blue}$(__kube_ps1)%f::%F{green}%2~%f$ '

# colorful listings
zmodload -i zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'
zstyle ':vcs_info:git:*' formats       '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'

# aliases
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'
alias mkdir='nocorrect mkdir'
alias j=jobs
if ls -F --color=auto >&/dev/null; then
  alias ls="ls --color=auto -F"
else
  alias ls="ls -F"
fi
alias l="ls -lah"
alias ll="ls -l"
alias l.='ls -d .[^.]*'
alias lsd='ls -ld *(-/DN)'
alias md='mkdir -p'
alias rd='rmdir'
alias cd..='cd ..'
alias ..='cd ..'
alias po='popd'
alias pu='pushd'
alias tsl="tail -f /var/log/syslog"
alias df="df -hT"
alias g="git"
alias mosh='mosh --server="LC_ALL=\"en_US.UTF-8\" mosh-server" '
alias vi=vim
alias v=nvim

alias k="kubectl" 
alias kg="kubectl get $1"
alias kgp="kubectl get pods"
alias kga="kubectl get all"
alias kgns="kubectl get namespace"
alias tmuxa="tmux attach-session"
alias tree="tree -I 'node_modules|venv|cache|__pycache__|test_*'"
alias kaf="kustomize build production | kubectl apply -f-"

# functions
setenv() { export $1=$2 }  # csh compatibility
sdate() { date +%Y.%m.%d }
clipcopy () { pbcopy < "${1:-/dev/stdin}" }
clippaste () { pbpaste }
ksns(){ kubectl config set-context $(kubectl config current-context) --namespace=${1-default} }
create-deployment() { kubectl create deployment $1 --image=$2 --dry-run=client --output=yaml > deployment.yaml }
get_namespace() { kubectl config view --minify -o jsonpath='{..namespace}' || return '' }
listening() {
  if [ $# -eq 0 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P
  elif [ $# -eq 1 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
  else
    echo "Usage: listening [pattern]"
  fi
}
push_changes() {
  git add .
  git commit -m "changes"
  git push origin $1
}

__kube_ps1()
{
    context=$(cat ~/.kube/config | grep "namespace:" | sed "s/namespace: //" | xargs)
    if [ -n "$context" ]; then
        echo "${context}"
    fi
}

__kube_ps2()
{
    context=$(cat ~/.kube/config | grep "cluster:" | sed "s/cluster: //" | tail -1 | xargs)
    max_length=24
    text_length=${#context}
    if [ -n "$context" ]; then
        if [ $text_length -gt $max_length ]; then
            echo "$context" | cut -c 1-$max_length
        else
            echo ${context}
        fi
    fi
}

# export
export CLICOLOR=1
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
source <(kubectl completion zsh)
export CI_SERVER_URL=https://gitlab.com
export AILAB_GROUP_ID=3707208
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

alias tmuxa="tmux attach"
