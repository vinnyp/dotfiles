#!/bin/bash
#
# Global environment variables.

# Core paths
# Note: Application specific paths (node, conda) are handled in their respective app modules.

# Homebrew Setup
# Check for Apple Silicon then Intel Mac / Linux default locations
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
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
