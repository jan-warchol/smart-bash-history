# ----------------------------
echo initial session
cd src/smart-bash-history
ls -l
git log --oneline --graph
history
tmux
# split window

# ----------------------------
echo pane on the right
git status
# switch pane

# ----------------------------
echo pane on the left
git branch
# search for ls
history
# switch pane

# search for git log
git log --oneline --graph
history


# search for recent commands
# tmux detach

history
# prefix search for echo right
ls -thor

