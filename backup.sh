#!/bin/bash

# Ensure we have a backup and check that we didn't loose history.

HISTBACKUP="${HISTFILE}.bak"

if [[ -e $HISTFILE ]]; then
  histfile_size=$(stat --printf="%s" "$HISTFILE" 2>/dev/null)
  histbackup_size=$(stat --printf="%s" "$HISTBACKUP" 2>/dev/null)

  if [[ -e $HISTBACKUP && $histfile_size -lt $histbackup_size ]]; then
    echo History file "$HISTFILE" shrank since it was backed up!
    echo You may want to compare it with the backup file:
    echo
    ls -hog "$HISTFILE" "$HISTBACKUP"
    echo
    echo Refusing to overwrite backup file.
  else  # update backup
    \cp "$HISTFILE" "$HISTBACKUP"
  fi
else
  if [[ -e $HISTBACKUP ]]; then
    echo History file "$HISTFILE" disappeared!
    echo You may want to restore it from backup file: "$HISTBACKUP"
  fi
fi
