# interactive, fuzzy history search (requires https://github.com/junegunn/fzf)
if which fzf >/dev/null; then
  __history_fzf_search() (
    __reload_history
    # remove entry numbers and timestamps (if any)
    HISTTIMEFORMAT= history | sed 's/^ *\([0-9]*\)\** *//' |
      fzf --height 50% --tiebreak=index --bind=ctrl-r:toggle-sort \
      --tac --sync --no-multi "--query=$*" ||
      # restore typed input if fzf aborted
      echo $*
  )
  # replace default Ctrl-R mapping
  bind '"\er": redraw-current-line'  # helper
  bind '"\C-r": " \C-e\C-u`__history_fzf_search \C-y`\e\C-e\er"'
fi

