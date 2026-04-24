#!/bin/bash
#
# Node & NPM configurations.

# NVM Configuration
export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
    # Load NVM
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    fi

    # Load NVM bash completion
    if [ -s "$NVM_DIR/bash_completion" ]; then
        source "$NVM_DIR/bash_completion"
    fi
fi

# List globally installed npm packages
npmls() {
    npm ls -gp | awk -F/ '/node_modules/ && !/node_modules.*node_modules/ {print $NF}'
}
