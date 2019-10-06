Smart history
-------------

Default shell history behaviour was designed in the 90s. A lot has
changed since then - time to catch up!

Features:

- fast, interactive search interface using
  [fzf](https://github.com/junegunn/fzf)
- synchronization across multiple terminals (_entries from current session stay
  on top!_)
- unlimited history (plus a command to remove duplicates)
- automatic backup and protection against terminal crashes
- convenient deleting of bad entries (so that you don't re-run a command with a
  typo)

All of this using less than 150 lines of shell script, without changing history
file format.



Installation
------------

1.  Clone the repo and make sure bash will load
    [`01-main-settings.sh`](./01-main-settings.sh) on startup (**Note: Mac**
    users should update `~/.bash_profile` instead of `~/.bashrc`):

        git clone https://github.com/jan-warchol/smart-bash-history.git
        echo 'source $HOME/smart-bash-history/01-main-settings.sh' >> ~/.bashrc

2.  Download [fzf](https://github.com/junegunn/fzf-bin/releases) into
    `smart-bash-history`. Assuming **64-bit Linux**:

        cd smart-bash-history
        wget https://github.com/junegunn/fzf-bin/releases/download/0.18.0/fzf-0.18.0-linux_amd64.tgz -O- | tar xz

3.  New shell sessions should have smart history enabled.



Usage
-----

Press `Ctrl-R` and start typing to interactively search history (you can
use arrows). Confirm selection by pressing return. `history`
command itself works the same as before.

To filter your history file, removing trivial commands and keeping only one
occurrence of each entry, run `filter_bash_history`.

To remove entries that include `rm -rf foobar`:

    hrm rm -rf foobar

(mnemonic: History ReMove).


### Gotchas

- History entry numbers change on each reload (by default on each prompt)
- multiline commands aren't well tested
