#!/bin/bash
#
# Git configurations and completion.

# Note: Git prompt support is handled in lib/prompt.sh

# Load Git completion
# 1. Try Homebrew location if brew is installed
if command -v brew &> /dev/null; then
    if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
        source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
    fi
fi

# 2. Try local lib location
# Assuming directory structure: `${HOME}/bash/apps/git.sh` -> `${HOME}/bash/lib/git-completion.bash`
GIT_COMPLETION_LIB="${HOME}/bash/lib/git-completion.bash"
if [ -f "$GIT_COMPLETION_LIB" ]; then
    source "$GIT_COMPLETION_LIB"
fi
