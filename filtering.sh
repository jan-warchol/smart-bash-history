#!/bin/bash

# Remove duplicates and uninteresting entries from supplied history file.
filter_bash_history() {
  if [ $# != 1 ]; then
    echo "Wrong number of arguments."
    echo "Usage: filter_bash_history <history file to process>"
    return 1
  fi

  cat "$1" |

  # Normalize commands for better deduplication ############

  # trim leading and trailing whitespace
  sed -r 's/^\s+//; s/\s+$//' |


  # Remove uninteresting commands ##########################

  # prepend placeholder timestamp to commands that didn't have one;
  # join timestamp and command into one line for further processing
  sed -n '/^#[0-9]*$/!{s/^/#0000000001 /; p}; /^#[0-9]*$/{N; s/\n/ /g; p;}' |

  # remove short commands (up to 6 characters)
  sed -r '/^#[0-9]* .{0,6}$/d' |

  # remove short git commands
  sed -r '/^#[0-9]* git .{1,8}$/d' |

  # remove short cd commands
  sed -r '/^#[0-9]* cd (\/home\/)?.{1,16}$/d' |

  # remove man commands
  sed -r '/^#[0-9]* man (git )?.[a-z_\-]*$/d' |


  # Deduplicate ############################################

  # sort by timestamp, keeping untimestamped commands at the beginning in
  # original order
  sort --stable --key=1,1 |

  # remove duplicates (keeping *last* occurrence). See
  # https://stackoverflow.com/questions/39076336/bash-remove-duplicates-preserve-order
  tac | awk '!uniq[substr($0, 12)]++' | tac |

  # split entries in two lines again, remove placeholder timestamps
  sed -r 's/^(#[0-9]*) /\1\n/' | grep -v "^#0000000001$" > "$1.filtered"

  backup_path="$1.$(date +%F.%T)~"
  \mv "$1" --no-clobber "$backup_path"
  \mv "$1.filtered" --no-clobber "$1"

  echo \"$1\" filtered.
  echo Original history saved to "$backup_path"
}
