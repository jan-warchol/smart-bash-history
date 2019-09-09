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

