#!/bin/bash

# Remove duplicates and uninteresting entries from supplied history file.
filter_bash_history() {
  file="${1:-$HISTFILE}"
  backup_path="$file.before-filtering.bak"
  echo -n Filtering \"$file\"...

  \mv "$file" "$backup_path"
  cat "$backup_path" |

  # Normalize commands for better deduplication ############

  # trim leading and trailing whitespace
  sed -r 's/^\s+//; s/\s+$//' |

  # prepend placeholder timestamp to commands that didn't have one;
  # join timestamp and command into one line for further processing
  sed -n '/^#[0-9]*$/!{s/^/#0000000001 /; p}; /^#[0-9]*$/{N; s/\n/ /g; p;}' |


  # Remove uninteresting commands ##########################

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
  sed -r 's/^(#[0-9]*) /\1\n/' | grep -v "^#0000000001$" > "$file"

  echo " done."
  echo Original history saved to "$backup_path"
}
