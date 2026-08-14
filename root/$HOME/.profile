# shellcheck shell=sh
# Read by whatever runs a login shell rather than executed, so it carries no
# shebang and names its shell here instead.

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	# shellcheck source=/dev/null # .bashrc is the distribution's, not in this repo.
	. "$HOME/.bashrc"
    fi
fi

