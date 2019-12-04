# keep lots of  history and don't overwrite history file after each session
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
setopt append_history hist_ignore_space hist_ignore_dups

# unique suffix -> simpler backups if you have many systems
# export HISTFILE="$HOME/.bash_history.$(hostname)"
export HISTBACKUP="${HISTFILE}.bak"

# don't save duplicates and commands starting with space
setopt hist_ignore_space hist_ignore_dups
# as well as any one-letter commands and some common commands
export HISTORY_IGNORE="(?|ls|la|ll|fg|hrn}"

# load remaining history configuration files (must use full path)
repo_root=$(dirname $0)
export PATH="$PATH:$repo_root"
source $repo_root/backup.sh
# source $repo_root/fuzzy-search.sh
# source $repo_root/synchronization.sh
# source $repo_root/filtering.sh
