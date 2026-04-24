#!/bin/bash
#
# Git configurations and completion.
#
# Note: Git prompt support is handled in lib/prompt.sh

# Load Git completion — try sources in priority order, stop once loaded.
# Uses $HOMEBREW_PREFIX (set by 'brew shellenv' in lib/env.sh) instead of
# spawning a 'brew --prefix' subprocess on every shell start.

# 1. Homebrew-installed git completion
if [ -n "$HOMEBREW_PREFIX" ] && \
   [ -f "${HOMEBREW_PREFIX}/etc/bash_completion.d/git-completion.bash" ] && \
   ! type __git_wrap__git_main &>/dev/null; then
    source "${HOMEBREW_PREFIX}/etc/bash_completion.d/git-completion.bash"
fi

# 2. System git completions from Xcode Command Line Tools
_GIT_COMPLETION_SYSTEM="/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
if [ -f "$_GIT_COMPLETION_SYSTEM" ] && ! type __git_wrap__git_main &>/dev/null; then
    source "$_GIT_COMPLETION_SYSTEM"
fi
unset _GIT_COMPLETION_SYSTEM

# 3. Final fallback: vendored copy in lib/ (git_completion.bash, underscore)
_GIT_COMPLETION_LIB="${HOME}/bash/lib/git_completion.bash"
if [ -f "$_GIT_COMPLETION_LIB" ] && ! type __git_wrap__git_main &>/dev/null; then
    source "$_GIT_COMPLETION_LIB"
fi
unset _GIT_COMPLETION_LIB
