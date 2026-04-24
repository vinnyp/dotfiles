#!/bin/bash
#
# uv — Python package and project manager.
# https://github.com/astral-sh/uv
#
# uv is installed at ~/.local/bin/uv (added to PATH via init.sh section 6).

# Load shell completions if uv is available.
# Completions are cached to ~/.cache/uv-completion.bash and regenerated only
# when the uv binary is newer than the cache (i.e. after a uv update).
if command -v uv &>/dev/null; then
    _uv_completion_cache="${HOME}/.cache/uv-completion.bash"
    if [ ! -f "$_uv_completion_cache" ] || \
       [ "$(command -v uv)" -nt "$_uv_completion_cache" ]; then
        mkdir -p "${HOME}/.cache"
        uv generate-shell-completion bash > "$_uv_completion_cache" 2>/dev/null
    fi
    [ -s "$_uv_completion_cache" ] && source "$_uv_completion_cache"
    unset _uv_completion_cache
fi
