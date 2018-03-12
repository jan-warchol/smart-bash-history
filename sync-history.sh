
# shell history is very useful; keep many months of history
export HISTFILESIZE=-1
export HISTSIZE=-1
export HISTCONTROL=ignoreboth
shopt -s histappend   # don't overwrite history file after each session
# I prefer to keep my history in my data folder so that it's backed up
export HISTFILE="$HOME/data/history/bash-history-$DISAMBIG_SUFFIX"
export HISTTIMEFORMAT="%d/%m/%y %T "

# ensure we have necessary dirs and a backup not older than an hour
mkdir -p `dirname $HISTFILE`
[ -z `find $HISTFILE.backup~ -mmin -60 2>/dev/null` ] &&
  cp --backup $HISTFILE $HISTFILE.backup~

split_history_file () {
  echo "Archiving old bash history for better performance..."
  archive_file="$HISTFILE.archive.$(date +%F.%H:%M:%S)"
  split -n "l/2" "$HISTFILE" "$HISTFILE.split_"
  mv "$HISTFILE.split_aa" "$archive_file"
  mv "$HISTFILE.split_ab" "$HISTFILE"
  echo -n $(sed '/^#[0-9]\+$/d' "$archive_file" | wc | awk '{print $1}')
  echo " entries archived to `basename $archive_file`"
  echo $(sed '/^#[0-9]\+$/d' "$HISTFILE" | wc | awk '{print $1}') entries remaining.
}

# write session history to dedicated file and sync with other sessions, always
# keeping history from current session on top.
# Note that HISTFILESIZE shouldn't be too big, or there will be a noticeable
# delay. A value of 100000 seems to work reasonable.
update_history () {
  history -a ${HISTFILE}.$$

  begin=$(date +%s.%N)
  history -c
  history -r
  end=$(date +%s.%N)
  ((`echo "$end - $begin > .1" | bc`)) && split_history_file
  for f in ${HISTFILE}.[0-9]*; do
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
orphaned_files=`ls $HISTFILE.[0-9]* 2>/dev/null | grep -v $grep_pattern`

if [ -n "$orphaned_files" ]; then
  echo Merging orphaned history files:
  for f in $orphaned_files; do
    echo "  `basename $f`"
    cat $f >> $HISTFILE
    rm $f
  done
  echo "done."
fi
