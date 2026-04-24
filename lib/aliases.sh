#!/bin/bash
#
# General shell aliases.

# Safety and defaults
alias cp='cp -iv'                           # Preferred 'cp' implementation
alias mv='mv -iv'                           # Preferred 'mv' implementation
alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
alias less='less -FSRXc'                    # Preferred 'less' implementation

# Directory navigation
alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels
alias ~="cd ~"                              # ~:            Go Home

# List directory contents
alias ll='ls -FGlAhp'                       # Preferred 'ls' implementation
alias ls='ls -G'                            # Enable colorized ls

# General utilities
alias edit='subl'                           # edit:         Opens any file in sublime editor
alias c='clear'                             # c:            Clear terminal display
alias which='type -all'                     # which:        Find executables
alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
alias show_options='shopt'                  # Show_options: display bash options settings
alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive
alias numFiles='echo $(ls -1 | wc -l)'      # numFiles:     Count of non-hidden files in current dir

# Network utilities (General)
alias myip='curl ip.appspot.com'            # myip:         Public facing IP Address

# Resource usage
alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

# ----------------------------------------------------------------------
# OS-Specific Aliases
# ----------------------------------------------------------------------

if [[ "$(uname)" == "Darwin" ]]; then
    # Finder operations
    alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder

    # MacOS System operations
    alias trash='command mv "$@" ~/.Trash'      # trash:        Moves a file to the MacOS trash
    alias ql='qlmanage -p "$*" >& /dev/null'    # ql:           Opens any file in MacOS Quicklook Preview
    alias dt='tee ~/Desktop/terminalOut.txt'    # DT:           Pipe content to file on MacOS Desktop

    # Clipboard integration
    alias pbcopy='pbcopy'
    alias pbpaste='pbpaste'

    # Finder Visibility
    alias finder_show_hidden='defaults write com.apple.finder ShowAllFiles TRUE'
    alias finder_hide_hidden='defaults write com.apple.finder ShowAllFiles FALSE'

    # Single User Mode Mount
    alias mount_read_write='/sbin/mount -uw /'

    # Cleanup DS_Store
    alias cleanup_ds="find . -type f -name '*.DS_Store' -ls -delete"

    # Flush DNS
    alias flush_dns='dscacheutil -flushcache'
fi
