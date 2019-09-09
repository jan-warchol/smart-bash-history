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

