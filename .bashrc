#!/bin/bash
#
# .bashrc
# Sourced by non-login interactive shells (and by .bash_profile for login shells).

# Return early for non-interactive shells (scp, rsync, remote commands, etc.)
[[ $- == *i* ]] || return

# Source the main initialization script
if [ -f "${HOME}/bash/init.sh" ]; then
    source "${HOME}/bash/init.sh"
fi
