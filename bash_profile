#!/bin/bash
#
# bash_profile
# Sourced by login shells (via the ~/.bash_profile shim, which sources this file).

# Source the repo bashrc if it exists (which sources init.sh and all modules).
if [ -f "${HOME}/bash/bashrc" ]; then
    source "${HOME}/bash/bashrc"
fi
