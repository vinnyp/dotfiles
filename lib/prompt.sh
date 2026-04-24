#!/bin/bash
#
# Bash prompt configuration.

# shellcheck disable=SC1090
source "${HOME}/bash/lib/git-prompt.sh"

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
