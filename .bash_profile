#!/bin/bash
#
# .bash_profile
# Sourced by login shells.

# Source .bashrc if it exists
if [ -f "${HOME}/bash/.bashrc" ]; then
    source "${HOME}/bash/.bashrc"
fi

. "$HOME/.local/bin/env"
