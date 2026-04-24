#!/bin/bash
#
# .bash_profile
# Sourced by login shells.

# Source .bashrc if it exists (which sources init.sh and all modules)
if [ -f "${HOME}/bash/.bashrc" ]; then
    source "${HOME}/bash/.bashrc"
fi
