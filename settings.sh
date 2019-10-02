# keep unlimited history and don't overwrite history file after each session
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend

export HISTFILE="$HOME/.bash_history.$(hostname)"
export HISTBACKUP="${HISTFILE}.bak"

# keep command timestamps and display them in ISO 8601-like format
export HISTTIMEFORMAT="%F.%T "

# don't save duplicates and commands starting with space
export HISTCONTROL="ignorespace:ignoredups"
# as well as any one-letter commands and some common commands
export HISTIGNORE="?:ls:la:ll:fg:hrn"

# disable terminal flow control key binding, so that ^S will search history forward
stty -ixon

# ensure we have a backup and check that we didn't loose stuff
histfile_size=$(stat --printf="%s" $HISTFILE 2>/dev/null)
histbackup_size=$(stat --printf="%s" $HISTBACKUP 2>/dev/null)
if [[ -e $HISTBACKUP && $histfile_size -lt $histbackup_size ]]; then
    echo Warning!
    echo History file \"$(basename $HISTFILE)\" shrinked since it was backed up.
    echo You may want to compare it with the backup file:
    ls -hog $HISTFILE $HISTBACKUP
    echo
    echo Refusing to overwrite backup file.
  else  # update backup
    [ -e $HISTFILE ] && cp $HISTFILE $HISTBACKUP
fi

# load remaining history configuration files
# (we must use full path and cannot rely on $0 because of sourcing quirks)
repo_root=$(dirname ${BASH_SOURCE})
source $repo_root/synchronization.sh
source $repo_root/filtering.sh
source $repo_root/entry-pruning.sh
