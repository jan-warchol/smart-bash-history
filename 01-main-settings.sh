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

# we cannot rely on $0 because of sourcing quirks
repo_root=$(dirname ${BASH_SOURCE})
export PATH="$PATH:$repo_root"

# interactive, fuzzy history search (requires https://github.com/junegunn/fzf)
if which fzf >/dev/null; then
  __history_fzf_search() (
    __reload_history
    # remove entry numbers and timestamps (if any)
    HISTTIMEFORMAT= history | sed 's/^ *\([0-9]*\)\** *//' |
      fzf --height 50% --tiebreak=index --bind=ctrl-r:toggle-sort \
      --tac --sync --no-multi "--query=$*" ||
      # restore typed input if fzf aborted
      echo $*
  )
  # replace default Ctrl-R mapping
  bind '"\er": redraw-current-line'  # helper
  bind '"\C-r": " \C-e\C-u`__history_fzf_search \C-y`\e\C-e\er"'
fi

# load remaining history configuration files (must use full path)
source $repo_root/synchronization.sh
source $repo_root/filtering.sh
source $repo_root/entry-pruning.sh
