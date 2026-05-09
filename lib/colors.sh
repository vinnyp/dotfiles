#!/bin/bash
#
# Color definitions and configurations.
#
# References:
#   http://linux-sxs.org/housekeeping/lscolors.html
#   http://geoff.greer.fm/lscolors/
#   http://en.wikipedia.org/wiki/ANSI_escape_code#graphics

# Enable color support for ls (GNU coreutils gnubin vs BSD /bin/ls).
# Use `command ls` so this stays correct even if ls is aliased later.
if command ls --version >/dev/null 2>&1 &&
  command ls --version 2>&1 | grep -qi gnu; then
  export BASH_LS_IS_GNU=1
  unset CLICOLOR  # BSD-specific; harmless if set but clearer without
  export LS_COLORS='di=1;36;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:*.rpm=90'
  unset LSCOLORS
else
  export BASH_LS_IS_GNU=0
  unset LS_COLORS
  export CLICOLOR=1
  export LSCOLORS="Gxfxcxdxbxegedabagacad"
fi

# Long listing used by cd() and similar — GNU ls uses -G for "no group", not color.
bash_ls_long() {
  if [[ ${BASH_LS_IS_GNU:-0} == 1 ]]; then
    command ls --color=auto -FlAhp "$@"
  else
    command ls -FGlAhp "$@"
  fi
}

# ANSI Colors
export NOCOLOR="\033[0m"
export BOLD="\033[1m"
export BLACK="\033[0;30m"
export DARK_GRAY="\033[1;30m"
export BLUE="\033[0;34m"
export LIGHT_BLUE="\033[1;34m"
export GREEN="\033[0;32m"
export LIGHT_GREEN="\033[1;32m"
export CYAN="\033[0;36m"
export LIGHT_CYAN="\033[1;36m"
export RED="\033[0;31m"
export LIGHT_RED="\033[1;31m"
export PURPLE="\033[0;35m"
export MAGENTA="\033[1;35m"
export BURNT="\033[0;33m"
export YELLOW="\033[1;33m"
export LIGHT_GRAY="\033[0;37m"
export WHITE="\033[1;37m"
export RESET="\033[0m"

# Man page colors
export LESS_TERMCAP_mb=$'\E'${RED:4}          # begin blinking
export LESS_TERMCAP_md=$'\E'${LIGHT_RED:4}    # begin bold
export LESS_TERMCAP_me=$'\E'${NOCOLOR:4}      # end mode
export LESS_TERMCAP_se=$'\E'${NOCOLOR:4}      # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'        # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E'${NOCOLOR:4}      # end underline
export LESS_TERMCAP_us=$'\E'${LIGHT_GREEN:4}  # begin underline
