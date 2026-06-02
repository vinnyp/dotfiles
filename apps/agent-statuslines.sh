#!/bin/bash
# agent statuslines: ensure ~/.claude and ~/.gemini statusline scripts point at the
# dotfiles copies. Sourced by init.sh's apps/*.sh loop, so a fresh clone self-links on
# the first shell (no manual symlink step needed on a new Mac). Idempotent + guarded:
# only creates a symlink when the target is MISSING — it never clobbers a real file you
# already have.
#
# NOTE: the payload scripts themselves live in apps/claude/ and apps/gemini/ (subdirs),
# which the init.sh `apps/*.sh` glob does NOT reach (it is non-recursive). That matters:
# both payloads start with `input=$(cat)`, so if they were ever sourced on shell load
# they would HANG the shell waiting on stdin. This module must NOT read stdin.
__bash_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

__agent_statusline_ensure_link() {  # <repo-file> <target-symlink>
    local src="$1" dst="$2"
    [ -e "$src" ] || return 0          # nothing to link from
    [ -L "$dst" ] && return 0          # already a symlink — leave it
    [ -e "$dst" ] && return 0          # a real file is there — don't clobber
    mkdir -p "$(dirname "$dst")" && ln -s "$src" "$dst"
}

__agent_statusline_ensure_link "${__bash_root}/apps/claude/statusline-command.sh" "${HOME}/.claude/statusline-command.sh"
__agent_statusline_ensure_link "${__bash_root}/apps/gemini/statusline-command.sh" "${HOME}/.gemini/statusline-command.sh"

unset -f __agent_statusline_ensure_link
unset __bash_root
