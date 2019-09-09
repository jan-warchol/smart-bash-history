# I prefer to keep my history in my data folder so that it's backed up
export HISTDIR="$HOME/data/history"
export HISTFNAME="$DISAMBIG_SUFFIX"
export HISTFILE="$HISTDIR/$HISTFNAME"
export HISTMERGED="${HISTFILE}_$(date +%Y-%m)"
export HISTBACKUP="${HISTDIR}-backup/${HISTFNAME}_$(date +%Y-%m).bak"
mkdir -p $HISTDIR ${HISTDIR}-backup; touch $HISTMERGED

# enable keeping history timestamp and set format to ISO-8601
export HISTTIMEFORMAT="%F %T "

export HISTCONTROL=ignoreboth   # ignore duplicates and commands starting with space
export HISTIGNORE="?:cd:-:..:ls:ll:bg:fg:vim:cim:g:g s:g d:g-:hrn:hrn *:hrm *"

# disable terminal flow control key binding, so that ^S will search history forward
stty -ixon

# keep unlimited shell history because it's very useful
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend   # don't overwrite history file after each session


# ensure we have a backup and verify that we didn't loose stuff
if [[ -e $HISTBACKUP && \
  `stat --printf="%s" $HISTMERGED` -lt `stat --printf="%s" $HISTBACKUP` ]]; then
    echo Warning! It seems that history file shrank - verify the backup!
    ls -hog $HISTMERGED $HISTBACKUP
  else
    \cp $HISTMERGED $HISTBACKUP
fi


# Synchronize history between bash sessions
#
# Make history from other terminals available to the current one. However,
# don't mix all histories together - make sure that *all* commands from the
# current session are on top of its history, so that pressing up arrow will
# give you most recent command from this session, not from any session.
#
# Since history is saved on each prompt, this additionally protects it from
# terminal crashes.

# on every prompt, save new history to dedicated file and recreate full history
# by reading all files, always keeping history from current session on top.
update_history () {
  history -a ${HISTFILE}.$$
  history -c
  for f in $(
    # filtered archival files (from all hosts)
    ls $(dirname ${HISTFILE})/*_20??.filtered 2>/dev/null;
    # history from previous months
    ls ${HISTFILE}_20??-?? 2>/dev/null;
    # histories of other sessions
    ls ${HISTFILE}.[0-9]* 2>/dev/null | grep -v "${HISTFILE}.$$\$";
    # history of current session (should be on top)
    echo "${HISTFILE}.$$"
  ) ; do
    history -r $f
  done
}
if [[ "$PROMPT_COMMAND" != *update_history* ]]; then
  export PROMPT_COMMAND="update_history; $PROMPT_COMMAND"
fi


# merge session history into main history file on bash exit
merge_session_history () {
  cat ${HISTFILE}.$$ >> $HISTMERGED
  \rm ${HISTFILE}.$$
}
trap merge_session_history EXIT

# when I don't want to save history from a session
clear_session_history () {
  > "${HISTFILE}.$$"
}


# detect leftover files from crashed sessions and merge them back
active_shells=$(pgrep `ps -p $$ -o comm=`)
grep_pattern=`for pid in $active_shells; do echo -n "-e \.${pid}\$ "; done`
orphaned_files=`ls $HISTFILE.[0-9]* 2>/dev/null | grep -v $grep_pattern`

if [ -n "$orphaned_files" ]; then
  echo Merging orphaned history files:
  for f in $orphaned_files; do
    echo "  `basename $f`"
    cat $f >> $HISTMERGED
    \rm $f
  done
  echo "done."
fi

# Merge ALL history files into main history file (settles entry numbering).
# See commit message for detailed rationale and use-case.
flush_session_histories () {
  for session_file in $(ls ${HISTFILE}.[0-9]* 2>/dev/null); do
    echo Flushing $session_file
    cat "$session_file" >> "$HISTMERGED"
    \rm "$session_file"
  done
}

history_remove_last_entries() {
  file=$HISTFILE.$$
  count=${1:-1}
  file_length=$(wc -l < $file)
  delete_from=$(( $file_length - $count * 2 + 1 ))
  [ $delete_from -lt 1 ] && delete_from=1

  echo -e "About to remove $count entries from $file:\n"
  sed -n "$delete_from,\$p" $file |
    # color timestamps for easier reading
    sed "s/#[0-9]\+/[37m&1[0m/"

  echo ""
  read -r -p "Press <Enter> to confirm."
  sed -i "$delete_from,\$d" $file
}
alias hrn=history_remove_last_entries

history_remove_matching_entries() {
  search_path=$(find "$HISTDIR" -type f | grep -v jw-t430s_2016)
  pattern="$@"
  [ -z "$HIST_PRUNE_USE_REGEX" ] &&
    mode="--fixed-strings" || mode="--extended-regexp"
  echo ""

  for file in $search_path; do
    line_numbers=$(grep \
      --before-context=1 --no-group-separator --line-number \
      $mode "$pattern" $file |
      sed 's/[:-].*$/;/'
    )

    if [ -n "$line_numbers" ]; then
      echo -e "\033[1;37m$file\033[0m"  # header with filename
      sed -n "$(echo "$line_numbers" | sed 's/;/p;/g')" $file |
        # color timestamps for easier reading
        sed "s/#[0-9]\+/[37m&1[0m/"
        echo ""

      if [ -z "$HIST_PRUNE_DRY_RUN" ]; then
        echo "Removing entries from $file" 1>&2
        echo ""
        sed -i "$(echo $line_numbers | sed 's/;/d;/g')" $file
      fi
    fi
  done
}

hrm() {
  HIST_PRUNE_DRY_RUN=yes history_remove_matching_entries "$@"
  untimestamped="$HISTDIR/archive/jw-t430s_2016"
  echo -e "\n$untimestamped"
  sed -n -r "/$@/p" $untimestamped
  read -r -p "Press <Enter> to remove matching entries from history."
  history_remove_matching_entries "$@" >/dev/null
  echo "Removing entries from $untimestamped"
  sed -i -r "/$@/d" $untimestamped
}

hrmr() { HIST_PRUNE_USE_REGEX=yes hrm "$@"; }
