#!/bin/bash
#
# .bashrc
# Sourced by non-login interactive shells (and by .bash_profile for login shells).

# Source the main initialization script
if [ -f "${HOME}/bash/init.sh" ]; then
    source "${HOME}/bash/init.sh"
fi

. "$HOME/.local/bin/env"
