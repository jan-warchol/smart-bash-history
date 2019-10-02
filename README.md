Smart history
-------------

The way shell history behaves by default made sense in the 90s, but a lot has
changed since then. This project makes history a much more powerful tool.

Features:

- unlimited history
- filtering duplicates and entries not worth keeping
- each session has access to commands executed in other sessions (but the
  entries from current session stay on top)
- no history is lost in case of terminal or system crashes
- a backup is automatically created to protect from mistakes in processing
  history file
- convenient interface for deleting bad entries (to make sure you don't re-run
  a command with a typo)
- all of this using standard format of history file and just a couple dozen
  lines of shell script



Installation
------------

Clone the repo and make sure bash will load `01-main-settings.sh` on startup
(Note: Mac users should update `~/.bash_profile` instead of `~/.bashrc`):

    git clone https://github.com/jan-warchol/smart-bash-history.git
    echo 'source $HOME/smart-bash-history/01-main-settings.sh' >> ~/.bashrc

New shell sessions should have smart history features enabled.



Usage
-----

Recalling commands from history (and `history` command itself) works the same
as before.

To filter your history file, removing short and uninteresting commands and
keeeping only one occurrence of each commmand:

    filter_bash_history $HISTFILE

To remove entries that include `rm -rf foobar`:

    hrm rm -rf foobar

(mnemonic: History ReMove).
