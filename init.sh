#!/bin/bash
#
# Main initialization script for bash dotfiles.
# This script orchestrates the loading of all other modules.

# Determine the directory of this script
BASH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Load Core Libraries
# ----------------------
# Colors first, as other scripts may use them.
if [ -f "${BASH_ROOT}/lib/colors.sh" ]; then
    source "${BASH_ROOT}/lib/colors.sh"
fi

# Environment variables (PATH, EDITOR, etc.)
if [ -f "${BASH_ROOT}/lib/env.sh" ]; then
    source "${BASH_ROOT}/lib/env.sh"
fi

# Library functions
if [ -f "${BASH_ROOT}/lib/functions.sh" ]; then
    source "${BASH_ROOT}/lib/functions.sh"
fi

# General aliases
if [ -f "${BASH_ROOT}/lib/aliases.sh" ]; then
    source "${BASH_ROOT}/lib/aliases.sh"
fi

# 2. Load Prompt / VCS
# --------------------
# Prompt configuration (also sources git-prompt.sh internally)
if [ -f "${BASH_ROOT}/lib/prompt.sh" ]; then
    source "${BASH_ROOT}/lib/prompt.sh"
fi


# 3. Load Application Configurations
# ----------------------------------
# Loop through all scripts in apps/ and source them.
if [ -d "${BASH_ROOT}/apps" ]; then
    for app_config in "${BASH_ROOT}/apps/"*.sh; do
        if [ -f "$app_config" ]; then
            source "$app_config"
        fi
    done
fi

# 4. Load Secrets / PII
# ---------------------
# This file should not be checked into version control.
if [ -f "${BASH_ROOT}/secrets.sh" ]; then
    source "${BASH_ROOT}/secrets.sh"
fi

# 5. Load Local Overrides
# -----------------------
# For machine-specific configurations not meant for the repo.
if [ -f "${HOME}/.bashrc_local" ]; then
    source "${HOME}/.bashrc_local"
fi

# 6. ~/bin and ~/.local/bin PATH
# --------------------------------
# ~/bin — personal scripts and tools (e.g. ok.sh GitHub CLI).
if [ -d "${HOME}/bin" ] && [[ ":$PATH:" != *":${HOME}/bin:"* ]]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# ~/.local/bin — uv, uvx, and other user-installed tools.
# Uses the env shim if present, otherwise add directly.
if [ -f "${HOME}/.local/bin/env" ]; then
    source "${HOME}/.local/bin/env"
elif [ -d "${HOME}/.local/bin" ] && [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi
