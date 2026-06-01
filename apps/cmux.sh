#!/bin/bash
# cmux/ghostty config: ensure the ~/.config symlinks point at the dotfiles copies.
# Sourced by init.sh's apps/*.sh loop, so a fresh clone self-links on the first shell
# (no manual symlink step needed on a new Mac). Idempotent + guarded: only creates a
# symlink when the target is MISSING — it never clobbers a real file you already have.
__bash_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

__cmux_ensure_link() {  # <repo-file> <target-symlink>
    local src="$1" dst="$2"
    [ -e "$src" ] || return 0          # nothing to link from
    [ -L "$dst" ] && return 0          # already a symlink — leave it
    [ -e "$dst" ] && return 0          # a real file is there — don't clobber
    mkdir -p "$(dirname "$dst")" && ln -s "$src" "$dst"
}

__cmux_ensure_link "${__bash_root}/apps/cmux.json"      "${HOME}/.config/cmux/cmux.json"
__cmux_ensure_link "${__bash_root}/apps/ghostty-config" "${HOME}/.config/ghostty/config"

unset -f __cmux_ensure_link
unset __bash_root
