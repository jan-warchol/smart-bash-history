# keep unlimited shell history because it's very useful
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend   # don't overwrite history file after each session

export HISTFILE="$HOME/.bash_history.$(hostname)"
export HISTBACKUP="${HISTFILE}.bak"

# enable keeping history timestamp and set format to ISO-8601
export HISTTIMEFORMAT="%F %T "

export HISTCONTROL=ignoreboth   # ignore duplicates and commands starting with space
export HISTIGNORE="?:cd:-:..:ls:ll:bg:fg:vim:cim:g:g s:g d:g-:hrn:hrn *:hrm *"

# disable terminal flow control key binding, so that ^S will search history forward
stty -ixon

# ensure we have a backup and verify that we didn't loose stuff
if [[ -e $HISTBACKUP && \
  `stat --printf="%s" $HISTFILE` -lt `stat --printf="%s" $HISTBACKUP` ]]; then
    echo Warning! It seems that history file shrank - verify the backup!
    ls -hog $HISTFILE $HISTBACKUP
  else
    \cp $HISTFILE $HISTBACKUP
fi

# load remaining history configuration files
# (we must use full path and cannot rely on $0 because of sourcing quirks)
repo_root=$(dirname ${BASH_SOURCE})
source $repo_root/synchronization.sh
source $repo_root/filtering.sh
source $repo_root/entry-pruning.sh
