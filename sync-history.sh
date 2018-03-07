
# shell history is very useful; keep many months of history
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTCONTROL=ignoreboth
shopt -s histappend   # don't overwrite history file after each session
# I prefer to keep my history in my data folder so that it's backed up
export HISTFILE="$HOME/data/bash-history-$DISAMBIG_SUFFIX"
export HISTTIMEFORMAT="%d/%m/%y %T "

# write session history to dedicated file and sync with other sessions, always
# keeping history from current session on top.
# Note that HISTFILESIZE shouldn't be too big, or there will be a noticeable
# delay. A value of 100000 seems to work reasonable.
update_history () {
  history -a ${HISTFILE}.$$

  history -c
  history -r
  for f in ${HISTFILE}.*; do
    if [ $f != ${HISTFILE}.$$ ]; then
      history -r $f
    fi
  done
  history -r ${HISTFILE}.$$
}

# merge into main history file on bash exit (see trap below)
merge_history () {
  cat ${HISTFILE}.$$ >> $HISTFILE
  rm ${HISTFILE}.$$
}

export PROMPT_COMMAND='update_history'
trap merge_history EXIT

active_shells=`pgrep -f "$0"`
grep_pattern=`for pid in $active_shells; do echo -n "-e \.${pid}\$ "; done`
orphaned_files=`ls $HISTFILE.[0-9]* | grep -v $grep_pattern`

if [ -n "$orphaned_files" ]; then
  echo Orphaned history files:
  echo $orphaned_files
  echo -n Merging orphaned history files...

  for f in $orphaned_files; do
    cat $f >> $HISTFILE
    rm $f
  done

  echo " done."
fi
