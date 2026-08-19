#!/bin/bash
#
# Global environment variables.

# Order-preserving PATH dedupe. Splits $PATH on ':', keeps the FIRST occurrence
# of each non-empty directory, drops later duplicates, and rebuilds $PATH.
# Defensive backstop in case an installer re-adds an entry that init.sh's guards
# missed; invoked as the last step of init.sh (after all PATH mutations).
__dedupe_path() {
    local _old_ifs="$IFS"
    local _new_path="" _dir
    IFS=':'
    for _dir in $PATH; do
        # Skip empty segments (e.g. a leading/trailing/doubled ':').
        [ -n "$_dir" ] || continue
        # Append only if we haven't already kept this exact dir.
        case ":${_new_path}:" in
            *":${_dir}:"*) ;;
            *) _new_path="${_new_path:+${_new_path}:}${_dir}" ;;
        esac
    done
    IFS="$_old_ifs"
    export PATH="$_new_path"
}

# Core paths
# Note: Application specific paths (node, conda) are handled in their respective app modules.

# Homebrew Setup
# Check for Apple Silicon then Intel Mac / Linux default locations
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# GNU coreutils (brew install coreutils): put gnubin ahead of /usr/bin so `ls`
# is GNU during dotfile init — avoids BSD LSCOLORS with GNU ls (broken colors).
if [ -n "${HOMEBREW_PREFIX:-}" ]; then
    _bash_coreutils_gnubin="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
    if [ -d "${_bash_coreutils_gnubin}" ]; then
        export PATH="${_bash_coreutils_gnubin}:${PATH}"
    fi
    unset _bash_coreutils_gnubin
fi

# On Apple Silicon, Homebrew shellenv (above) already sets the correct paths.
# Only add /usr/local/bin on Intel Macs or Linux where Homebrew lives there.
if [ "$(uname -m)" != "arm64" ]; then
    export PATH="/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
fi

# Set Default Editor
export EDITOR=nano

# Set default blocksize for ls, df, du
export BLOCKSIZE=1k

# Bash History Configuration
# Larger bash history (allow 32^3 entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL=ignoredups

# Make some commands not show up in history
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"
