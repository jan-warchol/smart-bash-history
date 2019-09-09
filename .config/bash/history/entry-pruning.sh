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

history_remove_matching_entries() {
  search_path=$(find "$HISTDIR" -type f | grep -v jw-t430s_2016)
  pattern="$@"
  [ -z "$HIST_PRUNE_USE_REGEX" ] &&
    mode="--fixed-strings" || mode="--extended-regexp"
  echo ""

  for file in $search_path; do
    line_numbers=$(grep \
      --before-context=1 --no-group-separator --line-number \
      $mode "$pattern" $file |
      sed 's/[:-].*$/;/'
    )

    if [ -n "$line_numbers" ]; then
      echo -e "\033[1;37m$file\033[0m"  # header with filename
      sed -n "$(echo "$line_numbers" | sed 's/;/p;/g')" $file |
        # color timestamps for easier reading
        sed "s/#[0-9]\+/[37m&1[0m/"
        echo ""

      if [ -z "$HIST_PRUNE_DRY_RUN" ]; then
        echo "Removing entries from $file" 1>&2
        echo ""
        sed -i "$(echo $line_numbers | sed 's/;/d;/g')" $file
      fi
    fi
  done
}

hrm() {
  HIST_PRUNE_DRY_RUN=yes history_remove_matching_entries "$@"
  untimestamped="$HISTDIR/archive/jw-t430s_2016"
  echo -e "\n$untimestamped"
  sed -n -r "/$@/p" $untimestamped
  read -r -p "Press <Enter> to remove matching entries from history."
  history_remove_matching_entries "$@" >/dev/null
  echo "Removing entries from $untimestamped"
  sed -i -r "/$@/d" $untimestamped
}

hrmr() { HIST_PRUNE_USE_REGEX=yes hrm "$@"; }
