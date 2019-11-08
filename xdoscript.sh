run() {
  xdotool type --delay 50 "$*"
  sleep 0.1
  xdotool key "Return"
  sleep 2
}
terminator &
sleep 1

run echo initial session
run cd ~/src/smart-bash-history
run ls -l
run git log --oneline
xdotool key "q"
run history

run tmux
xdotool key ctrl+A shift+5
sleep 0.2
run "# ----------------------------"
run echo right pane
