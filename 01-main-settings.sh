#!/bin/bash

# keep unlimited history and don't overwrite history file after each session
export HISTFILESIZE=-1
export HISTSIZE=-1
shopt -s histappend

# don't save duplicates and commands starting with space
export HISTCONTROL="ignorespace:ignoredups"

# keep timestamps of commands and display them in ISO-8601-like format
export HISTTIMEFORMAT="%F %T "

# Load remaining history configuration files (must use full path).
# Note: we cannot rely on $0 because of sourcing quirks.
repo_root=$(dirname ${BASH_SOURCE})
export PATH="$PATH:$repo_root"

source $repo_root/backup.sh
source $repo_root/fuzzy-search.sh
source $repo_root/synchronization.sh
source $repo_root/filtering.sh
