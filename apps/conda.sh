#!/bin/bash
#
# Conda initialization.
#
# Uses the static profile.d script instead of running 'conda shell.bash hook'
# as a subprocess on every shell start (~100-200ms saved per shell).

if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
    source "/opt/anaconda3/etc/profile.d/conda.sh"
elif [ -d "/opt/anaconda3/bin" ] && [[ ":$PATH:" != *":/opt/anaconda3/bin:"* ]]; then
    export PATH="/opt/anaconda3/bin:$PATH"
fi
