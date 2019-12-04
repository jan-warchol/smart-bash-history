# interactive, fuzzy history search (requires https://github.com/junegunn/fzf)
if which fzf >/dev/null; then
  __history_fzf_search() {
    # __reload_history
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
    selected=(
      $(fc -l 1 | sed 's/^ *\([0-9]*\)\** *//' |
      FZF_DEFAULT_OPTS="--height 50% --tiebreak=index --bind=ctrl-r:toggle-sort
      --tac --sync --no-multi --query=${(q)LBUFFER}" fzf)
    )
    local ret=$?
    LBUFFER=$selected
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
  }
  zle     -N   __history_fzf_search
  bindkey '^R' __history_fzf_search
fi

