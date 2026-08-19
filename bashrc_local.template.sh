#!/bin/bash
# ~/.bashrc_local — machine-local overrides. NOT tracked by this repo.
#
#   cp bashrc_local.template.sh ~/.bashrc_local   then fill in your paths.
#
# WHY THIS EXISTS: this repo is PUBLIC. Anything naming a private project,
# host, or path belongs here, not in a tracked file. init.sh sources this
# LAST, so it also wins over anything the repo defines.
#
# Sourced by init.sh at step 5, BEFORE the ~/bin and ~/.local/bin PATH
# additions — so a PATH entry set here ends up BEHIND those. That is usually
# what you want; prepend explicitly if not.

# ── Project roots ─────────────────────────────────────────────────────────
# Replace <name> with your own. Delete what you don't use.

# export PROJECTS_ROOT="${HOME}/Projects"
# export NOTES_VAULT="${HOME}/Documents/Obsidian/<vault-name>"
# export PERSONAL_VAULT="${HOME}/Documents/Obsidian/<vault-name>"
# export PLUGINS_ROOT="${PROJECTS_ROOT}/<repo-name>"

# ── Tool config that references a private path ────────────────────────────
# export AQL_CONFIGS_PATH="${HOME}/<private-overlay>/configs"

# ── PATH additions ────────────────────────────────────────────────────────
# Prefer symlinking a tool's entrypoints into ~/.local/bin over adding its
# directory here — ~/.local/bin is already on PATH and survives the project
# moving. Most installers have a flag for this (e.g. `<tool>-doctor --install`).
#
# if [ -d "${SOME_PROJECT}/bin" ]; then
#     export PATH="${SOME_PROJECT}/bin:${PATH}"
# fi

# ── Local aliases / functions ─────────────────────────────────────────────
# Defined here OVERRIDE the repo's versions (this file sources last).
# alias foo='bar'
