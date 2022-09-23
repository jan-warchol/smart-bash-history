#!/bin/bash

# Interactive, fuzzy history search (requires https://github.com/junegunn/fzf).
if which fzf >/dev/null; then
  __fzf_history_search() {
    # get commands ran since last prompt in this session
    __reload_history

    # See https://github.com/junegunn/fzf/blob/master/shell/key-bindings.bash
    local output opts script
    opts="--height 50% $FZF_DEFAULT_OPTS -n2.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS +m --read0"
    script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
    output=$(
      builtin fc -lnr -2147483648 |
        last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e "$script" |
        FZF_DEFAULT_OPTS="$opts" fzf --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }

  # replace default Ctrl-R mapping
  bind -x '"\C-r": __fzf_history_search'
fi
