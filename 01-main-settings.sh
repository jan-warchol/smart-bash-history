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
    [ -e $HISTFILE ] && rm -f $HISTBACKUP && cp $HISTFILE $HISTBACKUP
fi

# we cannot rely on $0 because of sourcing quirks
repo_root=$(dirname $0)
export PATH="$PATH:$repo_root"

# interactive, fuzzy history search (requires https://github.com/junegunn/fzf)
if which fzf >/dev/null; then
  __history_fzf_search() {
    # __reload_history
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
    selected=(
      $(fc -l 1 | sed 's/^ *\([0-9]*\)\** *//' |
      FZF_DEFAULT_OPTS="--height 50% --tiebreak=index --bind=ctrl-r:toggle-sort
      --tac --sync --no-multi --query=${(q)LBUFFER}" fzf)
    )
    local ret=$?
    LBUFFER=$selected
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
  }
  zle     -N   __history_fzf_search
  bindkey '^R' __history_fzf_search
fi

# load remaining history configuration files (must use full path)
# source $repo_root/synchronization.sh
# source $repo_root/filtering.sh
# source $repo_root/entry-pruning.sh
