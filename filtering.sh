#!/bin/bash

filter_bash_history() {
  file="${1:-$HISTFILE}"
  backup="$file.before-filtering.bak"
  \mv "$file" "$backup"

  # trim leading and trailing whitespace
  cat "$backup" | sed -r 's/^\s+//; s/\s+$//' |

  # check whether commands have timestamps (man bash -> HISTTIMEFORMAT);
  # put timestamp and command in one line to make sorting possible.
  if grep -E "^#[0-9]{10}$" </dev/stdin >/dev/null; then
    # squashes multiline commands
    sed '1i\\' | tr '\n' ' ' | sed -r 's/ (#[0-9]{10}) /\n\1 /g' | sed '1d'
  else  # add placeholder
    sed -n '/^#[0-9]*$/!{s/^/#0000000000 /; p}' 
  fi |

  # remove trivial commands
  sed -r '/^#[0-9]* .{,6}$/d' |
  sed -r '/^#[0-9]* [a-zA-Z0-9 _/.]{,12}$/d' |

  # sort by timestamp
  sort --stable --key=1,1 |
  # deduplicate, keeping last occurrence (https://stackoverflow.com/a/39076527)
  tac | awk '!uniq[substr($0, 12)]++' | tac |

  # split entries in two lines again, remove placeholder timestamps
  sed -r 's/^(#[0-9]*) /\1\n/' | grep -v "^#0000000000$" > "$file"

  echo Done. Original history saved to \"$backup\".
}
