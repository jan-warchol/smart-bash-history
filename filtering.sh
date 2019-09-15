#!/bin/bash

# Groom bash history file, removing entries that are not interesting and
# duplicated.
if [ $# != 1 ]; then
  echo "Wrong number of arguments."
  echo "Usage: $0 <history file to process>"
fi

cat "$1" |

# Normalize commands for better deduplication

# trim leading and trailing whitespace
sed -r 's/^\s+//; s/\s+$//' |

# normalize "git" to "g"
sed 's/^git /g /' |


# Remove uninteresting commands

# prepend placeholder timestamp to commands that didn't have one;
# join timestamp and command into one line for further processing
sed -n '/^#[0-9]*$/!{s/^/#0000000001 /; p}; /^#[0-9]*$/{N; s/\n/ /g; p;}' |

# remove short commands (up to 6 characters)
sed -r '/^#[0-9]* .{0,6}$/d' |

# remove short git commands
sed -r '/^#[0-9]* g .{1,8}$/d' |

# remove short cd commands
sed -r '/^#[0-9]* cd (\/home\/)?.{1,16}$/d' |

# remove man commands
sed -r '/^#[0-9]* man (git )?.[a-z_\-]*$/d' |


# Deduplicate

# sort by timestamp, keeping untimestamped commands at the beginning in
# original order
sort --stable --key=1,1 |

# remove duplicates (keeping *last* occurrence). See
# https://stackoverflow.com/questions/39076336/bash-remove-duplicates-preserve-order
tac | awk '!uniq[substr($0, 12)]++' | tac |

# split entries in two lines again, remove placeholder timestamps
sed -r 's/^(#[0-9]*) /\1\n/' | grep -v "^#0000000001$" > "$1.filtered"

echo Trimmed history file saved to "$1.filtered"
