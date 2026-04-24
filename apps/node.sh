#!/bin/bash
#
# Node & NPM configurations.

# NVM Configuration
# -----------------
# NVM's nvm.sh adds ~200-500ms to shell startup. Use lazy loading:
# nvm/node/npm/npx are stub functions that load NVM on first call,
# then call through to the real command.
export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
    # Lazy-load NVM — only initialises when nvm/node/npm/npx is first called
    _nvm_load() {
        unset -f nvm node npm npx _nvm_load
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            source "$NVM_DIR/nvm.sh"
        else
            echo "nvm: failed to load $NVM_DIR/nvm.sh" >&2
        fi
    }
    nvm()  { _nvm_load; nvm  "$@"; }
    node() { _nvm_load; node "$@"; }
    npm()  { _nvm_load; npm  "$@"; }
    npx()  { _nvm_load; npx  "$@"; }

    # Bash completion is fast to source eagerly (it's a small file)
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

# List globally installed npm packages
npmls() {
    npm ls -gp | awk -F/ '/node_modules/ && !/node_modules.*node_modules/ {print $NF}'
}
