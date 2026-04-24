#!/bin/bash
#
# uv — Python package and project manager.
# https://github.com/astral-sh/uv
#
# uv is installed at ~/.local/bin/uv (added to PATH via init.sh section 6).

# Load shell completions if uv is available
if command -v uv &>/dev/null; then
    eval "$(uv generate-shell-completion bash)"
fi
