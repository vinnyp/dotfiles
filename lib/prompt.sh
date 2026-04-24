#!/bin/bash
#
# Bash prompt configuration.

# Load git-prompt.sh for __git_ps1 support.
# Prefer the system-provided version from Xcode CLT (up-to-date, not vendored).
# Fall back to the vendored copy in lib/ if CLT is not present.
# shellcheck disable=SC1090,SC1091
_GIT_PROMPT_SYSTEM="/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
if [ -f "$_GIT_PROMPT_SYSTEM" ]; then
    source "$_GIT_PROMPT_SYSTEM"
elif [ -f "${HOME}/bash/lib/git-prompt.sh" ]; then
    source "${HOME}/bash/lib/git-prompt.sh"
else
    echo "bash/prompt.sh: git-prompt.sh not found — git branch info will be absent from prompt" >&2
fi
unset _GIT_PROMPT_SYSTEM

# Utility function to check for parent directory
has_parent_dir() {
    test -d "$1" && return 0
    
    local current="."
    while [ ! "$current" -ef "$current/.." ]; do
        if [ -d "$current/$1" ]; then
            return 0
        fi
        current="$current/.."
    done
    
    return 1
}

# Determine version control system name
vcs_name() {
    if [ -d .svn ]; then
        echo "-[svn]"
    elif has_parent_dir ".git"; then
        echo "-[$(__git_ps1 'git %s')]"
    elif has_parent_dir ".hg"; then
        echo "-[hg $(hg branch)]"
    fi
}

# Set terminal window title to current working directory
PS1="\[\e]0;\w\a\]"

# Construct the prompt
# [Time]-[User@Host]-[PWD]-[VCS]
# $
#
# Colors defined in colors.sh are used here.
# Note: Variables from colors.sh are expected to be available (sourced before this).

# Helper for constructing colored prompt components
prompt_time="\[$BOLD\]\[$DARK_GRAY\][\[$LIGHT_BLUE\]\@\[$DARK_GRAY\]]"
prompt_user_host="-[\[$LIGHT_GREEN\]\u\[$YELLOW\]@\[$LIGHT_GREEN\]\h\[$DARK_GRAY\]]"
prompt_pwd="-[\[$MAGENTA\]\w\[$DARK_GRAY\]]"
prompt_vcs="\[$BURNT\]\$(vcs_name)"
prompt_end="\[$NOCOLOR\]\[$RESET\]\n\[$RESET\]\$ "

PS1+="\n${prompt_time}${prompt_user_host}${prompt_pwd}${prompt_vcs}${prompt_end}"
export PS1
