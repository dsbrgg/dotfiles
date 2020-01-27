# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH=/usr/local/opt/rabbitmq/sbin:/usr/local/Cellar/openvpn/2.4.8/sbin:/usr/local/opt/libpq/bin:/Users/dsbrgg/local/depot_tools/:$PATH

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="kolo"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git debian python sudo zsh-autosuggestions)

# https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

source $ZSH/oh-my-zsh.sh
source /usr/local/etc/profile.d/z.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias tmux="TERM=screen-256color tmux -u"
alias vim="/usr/local/bin/vim"
alias c="clear"

# NVM setup
export NVM_DIR="$HOME/.nvm"
source $(brew --prefix nvm)/nvm.sh
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# fzf for vim 
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fix warning message
export LC_ALL=en_US.UTF-8

# nnn env variables

export NNN_USE_EDITOR=1

############ scripts ############

# gln
# - prints git log with line number
# - has to be used on folder with .git
# - folder in it.
# - optional args: line number -> $1
#
# - eg. gln || gln 10
gln() { git log -$1 | nl -n ln; }

# ghex
# - extracts hex from git log line
# - eg. githex 10 -> 98b7a2e
ghex() { line=$(($1+1)) && git log | sed -n "${line}p" | cut -c 1-7; }

# rebaser
# - applies git rebase, based on a git log line
# - eg. rebaser 10
rebaser() { git rebase -i $(ghex $1) }

# dkrit
# - access container with shell
# - by the container id
# - eg. dkrit a0c1b67e
dkrit() { docker exec -it $1 /bin/sh; }

# dkrrmall
# - remove all containers from docker
# - eg. dkrrmall
dkrrmall() {
  docker container stop $(docker ps -a -q);
  yes | docker container prune;
}

# seegno docker aliases
dkr() {
  case $1 in
    rmc) echo -n "Are you sure you want to remove all containers?(y/n) "
         read answer
         case $answer:l in
           y|yes) docker rm $(docker ps -a -q) ;;
           *) ;;
         esac ;;
    rmi) echo -n "Are you sure you want to remove all images?(y/n) "
         read answer
         case $answer:l in
           y|yes) if [[ $2 == -f || $2 == --force ]] ; then docker rmi -f $(docker images -q)
                  else docker rmi $(docker images -q) ; fi ;;
           *) ;;
         esac ;;
    (kill|k)) docker kill $(docker ps -q) ;;
    reset) echo -e "\e[0;31mWARNING: This will clear all unused networks and delete all containers and images. \e[0;0m"
           echo -n "Are you sure you want to reset?(y/n) "
           read answer
           case $answer:l in
             y|yes) docker kill $(docker ps -q) | docker network prune | docker rm $(docker ps -q) | docker rmi $(docker images -q) ;;
             *) ;;
           esac ;;
    login) $(aws ecr get-login --no-include-email) ;;
    *) echo "Usage: $0 {rmc|rmi|kill|k|reset|login}" ;;
  esac
}
