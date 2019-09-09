# Utilities for removing unwanted history entries (e.g. wrong syntax used)

history_remove_last_entries() {
  file=$HISTFILE.$$
  count=${1:-1}
  file_length=$(wc -l < $file)
  delete_from=$(( $file_length - $count * 2 + 1 ))
  [ $delete_from -lt 1 ] && delete_from=1

  echo -e "About to remove $count entries from $file:\n"
  sed -n "$delete_from,\$p" $file |
    # color timestamps for easier reading
    sed "s/#[0-9]\+/[37m&1[0m/"

  echo ""
  read -r -p "Press <Enter> to confirm."
  sed -i "$delete_from,\$d" $file
}
alias hrn=history_remove_last_entries

__find_matching_lines() {
  [ $# -lt 2 ] && \
    echo "Usage: __find_matching_lines <pattern> <file> [<opts>]" && return 3
  default_matcher="--fixed-strings"

  pattern="$1"; file="$2";
  opts="${3:-$default_matcher}"
  # include previous line (with timestamp) if it's being saved by shell
  [ -n "$HISTTIMEFORMAT" ] && opts="--before-context=1 $opts"

  set -o pipefail
  grep --no-group-separator --line-number \
    $opts $MATCHER "$pattern" "$file" |
    sed 's/[:-].*$/;/'
  return $?
}

history_remove_matching_entries() {
  path=$(find "${HISTDIR:-$HISTFILE}" -type f)

  for file in $path; do
    line_numbers=$(__find_matching_lines "$*" "$file")
    if [ $? -gt 1 ]; then  # 1 means no results
      echo -e "Internal error during search! \n  $line_numbers"
      return 1
    fi

    if [ -n "$line_numbers" ]; then
      echo -e "\n\033[1;37m$file\033[0m"  # header with filename
      sed -n "$(echo "$line_numbers" | sed 's/;/p;/g')" "$file" |
        # color timestamps for easier reading
        sed "s/#[0-9]\+/[37m&1[0m/"

      if [ -z "$HIST_PRUNE_DRY_RUN" ]; then
        if [ -z "$HIST_PRUNE_FORCE" ]; then
          echo ""
          read -r -p "Press <Enter> to remove matching entries from history."
        fi
        echo "Removing entries from $file" 1>&2
        sed -i "$(echo $line_numbers | sed 's/;/d;/g')" $file
      fi
    fi
  done
}

hrm() {
  HIST_PRUNE_DRY_RUN=yes history_remove_matching_entries "$@"
  echo ""
  read -r -p "Press <Enter> to remove matching entries from history."
  HIST_PRUNE_FORCE=yes history_remove_matching_entries "$@" >/dev/null
}
