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

