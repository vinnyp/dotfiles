#!/bin/bash
#
# General shell functions.

# Change directory and list contents
cd() {
    builtin cd "$@" || return
    ls -FGlAhp
}

# Make directory and enter it
mcd() {
    mkdir -p "$1" && cd "$1"
}

# Find file under the current directory
ff() {
    find . -name "$@"
}

# Find file whose name starts with a given string
ffs() {
    find . -name "$@"'*'
}

# Find file whose name ends with a given string
ffe() {
    find . -name '*'"$@"
}

# Find process ID by name
find_pid() {
    lsof -t -c "$@"
}

# List processes owned by user
my_ps() {
    ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command
}

# Search manpage (case insensitive)
# Usage: mans <manpage> <term>
mans() {
    man "$1" | grep -iC2 --color=always "$2" | less
}

# Remind yourself of an alias
showa() {
    grep --color=always -i -a1 "$@" ~/bash/lib/aliases.sh | grep -v '^\s*$' | less -FSRXc
}

# Create a ZIP archive of a folder
zipf() {
    zip -r "$1".zip "$1"
}

# Extract most archives with one command
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    fi
}

# ----------------------------------------------------------------------
# OS-Specific Functions
# ----------------------------------------------------------------------

if [[ "$(uname)" == "Darwin" ]]; then
    # cdf:  'Cd's to frontmost window of MacOS Finder
    cdf() {
        local curr_folder_path
        curr_folder_path=$( /usr/bin/osascript <<EOT
            tell application "Finder"
                try
            set currFolder to (folder of the front window as alias)
                on error
            set currFolder to (path to desktop folder as alias)
                end try
                POSIX path of currFolder
            end tell
EOT
        )
        echo "cd to \"$curr_folder_path\""
        cd "$curr_folder_path" || return
    }

    # System Info
    ii() {
        echo -e "\nYou are logged on ${GREEN}$HOSTNAME${NOCOLOR}"
        echo -e "\nAdditionnal information:$NOCOLOR " ; uname -a
        echo -e "\n${RED}Users logged on:$NOCOLOR " ; w -h
        echo -e "\n${RED}Current date :$NOCOLOR " ; date
        echo -e "\n${RED}Machine stats :$NOCOLOR " ; uptime
        echo -e "\n${RED}Public facing IP Address :$NOCOLOR " ; myip
        if command -v scselect > /dev/null; then
            echo -e "\n${RED}Current network location :$NOCOLOR " ; scselect
        fi
        echo
    }

    # SSH Key Generation (Interactive)
    ssh_key_gen() {
        local name email
        echo "What's the name of the Key (no spaced please) ? "
        read -r name
        
        echo "What's the email associated with it? "
        read -r email
        
        ssh-keygen -t rsa -f ~/.ssh/"id_rsa_$name" -C "$email"
        pbcopy < ~/.ssh/"id_rsa_$name.pub"
        
        echo "SSH Key copied in your clipboard"
    }
fi
