# enable keeping history timestamp and set format to ISO-8601
export HISTTIMEFORMAT="%F %T "

export HISTCONTROL=ignoreboth   # ignore duplicates and commands starting with space
export HISTIGNORE="?:cd:-:..:ls:ll:bg:fg:vim:cim:g:g s:g d:g-"

# disable terminal flow control key binding, so that ^S will search history forward
stty -ixon

# keep unlimited shell history because it's very useful
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend   # don't overwrite history file after each session


# Synchronize history between bash sessions
#
# Make history from other terminals available to the current one. However,
# don't mix all histories together - make sure that *all* commands from the
# current session are on top of its history, so that pressing up arrow will
# give you most recent command from this session, not from any session.
#
# Since history is saved on each prompt, this additionally protects it from
# terminal crashes.

# ensure we have a backup that is not older than an hour, just in case
[ -z `find $HISTFILE.backup~ -mmin -60 2>/dev/null` ] &&
  \cp --backup $HISTFILE $HISTFILE.backup~
[ `stat --printf="%s" $HISTFILE.backup~` -lt `stat --printf="%s" $HISTFILE.backup~~` ] &&
  echo Warning! It seems that history file shrank - verify the backups!


# on every prompt, save new history to dedicated file and recreate full history
# by reading all files, always keeping history from current session on top.
update_history () {
  history -a ${HISTFILE}.$$
  history -c
  # read filtered archival files (from all hosts)
  for f in `ls $(dirname ${HISTFILE})/bash-history-*.filtered_* 2>/dev/null`; do
    history -r $f
  done
  # read unfiltered items
  history -r
  # load histories of other sessions
  for f in `ls ${HISTFILE}.[0-9]* 2>/dev/null | grep -v "${HISTFILE}.$$\$"`; do
    history -r $f
  done
  history -r "${HISTFILE}.$$"  # load current session history
}
if [[ "$PROMPT_COMMAND" != *update_history* ]]; then
  export PROMPT_COMMAND="update_history; $PROMPT_COMMAND"
fi


# merge session history into main history file on bash exit
merge_session_history () {
  cat ${HISTFILE}.$$ >> $HISTFILE
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
    cat $f >> $HISTFILE
    \rm $f
  done
  echo "done."
fi

# Merge ALL history files into main history file (settles entry numbering).
# See commit message for detailed rationale and use-case.
flush_session_histories () {
  for session_file in $(ls ${HISTFILE}.[0-9]* 2>/dev/null); do
    echo Flushing $session_file
    cat "$session_file" >> "$HISTFILE"
    \rm "$session_file"
  done
}

