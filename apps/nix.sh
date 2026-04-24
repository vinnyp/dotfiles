#!/bin/bash
#
# Nix package manager.
# https://nixos.org/download/
#
# Nix is installed as a multi-user daemon. Its PATH and environment are
# configured system-wide via /etc/bashrc (injected by the Nix installer),
# so no setup is needed here.
#
# To install on a new machine:
#   curl -L https://nixos.org/nix/install | sh -s -- --daemon
#
# After installation, /etc/bashrc will contain:
#   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
