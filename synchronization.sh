# on every prompt, save new history to dedicated file and recreate full history
# by reading all files, always keeping history from current session on top.
__reload_history () {
  history -a ${HISTFILE}.$$
  history -c
  for f in $(
    # main file with merged history
    ls $HISTFILE 2>/dev/null
    # histories of other sessions
    ls ${HISTFILE}.* 2>/dev/null | grep "\.[0-9]*$" | grep -v "${HISTFILE}.$$\$";
    # history of current session (should be on top)
    echo "${HISTFILE}.$$"
  ) ; do
    history -r $f
  done
}
if [[ "$PROMPT_COMMAND" != *__reload_history* ]]; then
  export PROMPT_COMMAND="__reload_history; $PROMPT_COMMAND"
fi

# append provided file to main history
__merge_history_file() {
  [ $# -ne 1 ] && echo "Missing argument" && return 1
  [ -e "$1" ] && file="$1" || return 0
  echo "Flushing $(basename $file)"
  cat "$file" >> "$HISTFILE"
  rm "$file"
}
flush_current_session_history() { __merge_history_file "${HISTFILE}.$$"; }
# run it automatically on bash exit
trap flush_current_session_history EXIT

# detect leftover files from crashed sessions and merge them back
# Login shells report comm as -bash. pgrep treats that leading dash as an option.
__shell_basename() {
  name=$1
  name=${name//[[:space:]]/}
  name=${name#-}
  name=${name##*/}
  printf '%s\n' "$name"
}

__active_shell_pids() {
  wanted=$(__shell_basename "$(ps -p $$ -o comm=)")
  ps -x -o pid=,comm= | while read -r pid comm; do
    if [ "$(__shell_basename "$comm")" = "$wanted" ]; then
      printf '%s\n' "$pid"
    fi
  done
}

active_shells=$(__active_shell_pids)
grep_pattern=$(for pid in $active_shells; do echo -n "-e \.${pid}\$ "; done)
orphaned_files=$(ls $HISTFILE.[0-9]* 2>/dev/null | grep -v $grep_pattern)

if [ -n "$orphaned_files" ]; then
  echo Found orphaned history files.
  for f in $orphaned_files; do
    echo -n "  "; __merge_history_file "$f"
  done; echo "done."
fi

