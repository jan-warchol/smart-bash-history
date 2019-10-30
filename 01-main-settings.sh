# keep unlimited history and don't overwrite history file after each session
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend

# unique suffix -> simpler backups if you have many systems
# export HISTFILE="$HOME/.bash_history.$(hostname)"
export HISTBACKUP="${HISTFILE}.bak"

# don't save duplicates and commands starting with space
export HISTCONTROL="ignorespace:ignoredups"
# as well as any one-letter commands and some common commands
export HISTIGNORE="?:ls:la:ll:fg:hrn"

# we cannot rely on $0 because of sourcing quirks
repo_root=$(dirname ${BASH_SOURCE})
export PATH="$PATH:$repo_root"

# load remaining history configuration files (must use full path)
source $repo_root/backup.sh
source $repo_root/fuzzy-search.sh
source $repo_root/synchronization.sh
source $repo_root/filtering.sh
source $repo_root/entry-pruning.sh
