#
#  Courtesy of http://natelandau.com/my-mac-osx-bash_profile/
#
#  ---------------------------------------------------------------------------
#
#  Description:  This file holds all my BASH configurations and aliases
#
#  Sections:
#  1.   Environment Configuration
#  2.   Make Terminal Better (remapping defaults and adding functionality)
#  3.   File and Folder Management
#  4.   Searching
#  5.   Process Management
#  6.   Networking
#  7.   System Operations & Information
#  8.   Web Development
#  9.   Git
#
#  ---------------------------------------------------------------------------


#   -------------------------------
#   1.  ENVIRONMENT CONFIGURATION
#   -------------------------------

#   Add color to ls
#   ------------------------------------------------------------

#   Detect which `ls` flavor is in use
    if ls --version > /dev/null 2>&1; then # OS X `ls` since --version doesn't exist!
        colorflag="-G"
    else # GNU `ls`
        colorflag="--color"
    fi
#   From http://osxdaily.com/2012/02/21/add-color-to-the-terminal-in-mac-os-x/)
    export CLICOLOR=1
    export LSCOLORS="Gxfxcxdxbxegedabagacad"

#   ls colors reference (http://linux-sxs.org/housekeeping/lscolors.html)
#   ls colors converter and palette picker (http://geoff.greer.fm/lscolors/)
    export LS_COLORS='di=1;36;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:*.rpm=90'

#   Add git info to the prompt
#   ------------------------------------------------------------

# Downloaded from link below.
# curl -o ~/.git-prompt.sh \ https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
    source ~/.git-prompt.sh

# Utility function so we can test for things like .git/.hg without firing up a separate process.
# Used for the prompt.
    __has_parent_dir () {
        test -d "$1" && return 0;

        current="."
        while [ ! "$current" -ef "$current/.." ]; do
            if [ -d "$current/$1" ]; then
                return 0;
            fi
            current="$current/..";
        done

        return 1;
    }

# Utility function to set the appropriate version control system on the prompt.
    __vcs_name() {
        if [ -d .svn ]; then
            echo "-[svn]";
        elif __has_parent_dir ".git"; then
            echo "-[$(__git_ps1 'git %s')]";
        elif __has_parent_dir ".hg"; then
            echo "-[hg $(hg branch)]"
        fi
    }


#   ANSI Colors
#   Reference: http://en.wikipedia.org/wiki/ANSI_escape_code#graphics
#   ------------------------------------------------------------
    export      NOCOLOR="\033[0m"
    export         BOLD="\033[1m"
    export        BLACK="\033[0;30m"
    export    DARK_GRAY="\033[1;30m"
    export         BLUE="\033[0;34m"
    export   LIGHT_BLUE="\033[1;34m"
    export        GREEN="\033[0;32m"
    export  LIGHT_GREEN="\033[1;32m"
    export         CYAN="\033[0;36m"
    export   LIGHT_CYAN="\033[1;36m"
    export          RED="\033[0;31m"
    export    LIGHT_RED="\033[1;31m"
    export       PURPLE="\033[0;35m"
    export      MAGENTA="\033[1;35m"
    export        BURNT="\033[0;33m"
    export       YELLOW="\033[1;33m"
    export   LIGHT_GRAY="\033[0;37m"
    export        WHITE="\033[1;37m"

#   Used to color man pages
    export LESS_TERMCAP_mb=$'\E'${RED:4}          # begin blinking
    export LESS_TERMCAP_md=$'\E'${LIGHT_RED:4}    # begin bold
    export LESS_TERMCAP_me=$'\E'${NOCOLOR:4}      # end mode
    export LESS_TERMCAP_se=$'\E'${NOCOLOR:4}      # end standout-mode
    export LESS_TERMCAP_so=$'\E[01;44;33m'        # begin standout-mode - info box
    export LESS_TERMCAP_ue=$'\E'${NOCOLOR:4}      # end underline
    export LESS_TERMCAP_us=$'\E'${LIGHT_GREEN:4}  # begin underline

#   Nicely formatted terminal window title and prompt
#   ------------------------------------------------------------
#   Set the terminal title to the current working directory
    PS1="\[\033]0;\w\007\]"

#   Set the bash prompt to the following:
#
#   [10:53 PM]-[user@machinename]-[~]-[git]
#   $
    PS1+="\n\[$BOLD\]\[$DARK_GRAY\][\[$LIGHT_BLUE\]\@\[$DARK_GRAY\]]-[\[$LIGHT_GREEN\]\u\[$YELLOW\]@\[$LIGHT_GREEN\]\h\[$DARK_GRAY\]]-[\[$MAGENTA\]\w\[$DARK_GRAY\]]\[$BURNT\]\$(__vcs_name)\[$NOCOLOR\]\[$RESET\]\n\[$RESET\]\$ "
    export PS1

#   Set Paths
#   ------------------------------------------------------------

#   These paths are needed to override system utils from "brew install coreutils"
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

#   Additional paths
    export PATH="$PATH:/usr/local/bin"
    export PATH="/usr/local/git/bin:/sw/bin:/usr/local/bin:/usr/local:/usr/local/sbin:/usr/local/mysql/bin:$PATH"

#   Node specific paths. The .node path is required if you follow these instructions: https://gist.github.com/DanHerbert/9520689
    export PATH="$HOME/.node/bin:$PATH"
#    export NODE_PATH="/usr/local/lib/node_modules:${NODE_PATH}"

#   Set Default Editor (change 'Nano' to the editor of your choice)
#   ------------------------------------------------------------
    export EDITOR=nano

#   Set default blocksize for ls, df, du
#   from this: http://hints.macworld.com/comment.php?mode=view&cid=24491
#   ------------------------------------------------------------
    export BLOCKSIZE=1k

#   Ruby config
#   Use Homebrew's directories rather than ~/.rbenv
#   Installing ruby (required) for this: `$ brew install rbenv ruby-build`
#   -------------------------------------------------------------------
    export RBENV_ROOT=/usr/local/var/rbenv

#   Enable Ruby shims and autocomplete
#   -------------------------------------------------------------------
    if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

#   Larger bash history (allow 32³ entries; default is 500)
#   -------------------------------------------------------------------
    export HISTSIZE=32768
    export HISTFILESIZE=${HISTSIZE}
    export HISTCONTROL=ignoredups

#   Make some commands not show up in history
#   -------------------------------------------------------------------
    export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"

#   -----------------------------
#   2.  MAKE TERMINAL BETTER
#   -----------------------------

    alias cp='cp -iv'                           # Preferred 'cp' implementation
    alias mv='mv -iv'                           # Preferred 'mv' implementation
    alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
    alias ll='ls -FlAhp ${colorflag}'           # Preferred 'ls' implementation
    alias ls='ls ${colorflag}'                  # Enable color when using ls from 'brew coreutils'
    alias less='less -FSRXc'                    # Preferred 'less' implementation
    cd() { builtin cd "$@"; ll; }               # Always list directory contents upon 'cd'
    alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
    alias ..='cd ../'                           # Go back 1 directory level
    alias ...='cd ../../'                       # Go back 2 directory levels
    alias .3='cd ../../../'                     # Go back 3 directory levels
    alias .4='cd ../../../../'                  # Go back 4 directory levels
    alias .5='cd ../../../../../'               # Go back 5 directory levels
    alias .6='cd ../../../../../../'            # Go back 6 directory levels
    alias edit='subl'                           # edit:         Opens any file in sublime editor
    alias f='open -a Finder ./'                 # f:            Opens current directory in MacOS Finder
    alias ~="cd ~"                              # ~:            Go Home
    alias c='clear'                             # c:            Clear terminal display
    alias which='type -all'                     # which:        Find executables
    alias path='echo -e ${PATH//:/\\n}'         # path:         Echo all executable Paths
    alias show_options='shopt'                  # Show_options: display bash options settings
    alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
    alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive
    mcd () { mkdir -p "$1" && cd "$1"; }        # mcd:          Makes new Dir and jumps inside
    trash () { command mv "$@" ~/.Trash ; }     # trash:        Moves a file to the MacOS trash
    ql () { qlmanage -p "$*" >& /dev/null; }    # ql:           Opens any file in MacOS Quicklook Preview
    alias DT='tee ~/Desktop/terminalOut.txt'    # DT:           Pipe content to file on MacOS Desktop

#   timer: Stop watch
#   ------------------------------------------
    alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
    alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.             Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () {
        man $1 | grep -iC2 --color=always $2 | less
    }

#   showa: to remind yourself of an alias (given some part of it)
#   ------------------------------------------------------------
    showa () { /usr/bin/grep --color=always -i -a1 $@ ~/Library/init/bash/aliases.bash | grep -v '^\s*$' | less -FSRXc ; }

#   -------------------------------
#   3.  FILE AND FOLDER MANAGEMENT
#   -------------------------------

    zipf () { zip -r "$1".zip "$1" ; }          # zipf:         To create a ZIP archive of a folder
    alias numFiles='echo $(ls -1 | wc -l)'      # numFiles:     Count of non-hidden files in current dir
    alias make1mb='mkfile 1m ./1MB.dat'         # make1mb:      Creates a file of 1mb size (all zeros)
    alias make5mb='mkfile 5m ./5MB.dat'         # make5mb:      Creates a file of 5mb size (all zeros)
    alias make10mb='mkfile 10m ./10MB.dat'      # make10mb:     Creates a file of 10mb size (all zeros)

#   cdf:  'Cd's to frontmost window of MacOS Finder
#   ------------------------------------------------------
    cdf () {
        currFolderPath=$( /usr/bin/osascript <<EOT
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
        echo "cd to \"$currFolderPath\""
        cd "$currFolderPath"
    }

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
    extract () {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
             esac
         else
             echo "'$1' is not a valid file"
         fi
    }


#   ---------------------------
#   4.  SEARCHING
#   ---------------------------

    alias qfind="find . -name "                 # qfind:    Quickly search for file
    ff () { /usr/bin/find . -name "$@" ; }      # ff:       Find file under the current directory
    ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs:      Find file whose name starts with a given string
    ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe:      Find file whose name ends with a given string

#   spotlight: Search for a file using MacOS Spotlight's metadata
#   -----------------------------------------------------------
    spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }


#   ---------------------------
#   5.  PROCESS MANAGEMENT
#   ---------------------------

#   findPid: find out the pid of a specified process
#   -----------------------------------------------------
#       Note that the command name can be specified via a regex
#       E.g. findPid '/d$/' finds pids of all processes with names ending in 'd'
#       Without the 'sudo' it will only find processes of the current user
#   -----------------------------------------------------
    findPid () { lsof -t -c "$@" ; }

#   memHogsTop, memHogsPs:  Find memory hogs
#   -----------------------------------------------------
    alias memHogsTop='top -l 1 -o rsize | head -20'
    alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#   cpuHogs:  Find CPU hogs
#   -----------------------------------------------------
    alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#   topForever:  Continual 'top' listing (every 10 seconds)
#   -----------------------------------------------------
    alias topForever='top -l 9999999 -s 10 -o cpu'

#   ttop:  Recommended 'top' invocation to minimize resources
#   ------------------------------------------------------------
#       Taken from this macosxhints article
#       http://www.macosxhints.com/article.php?story=20060816123853639
#   ------------------------------------------------------------
    alias ttop="top -R -F -s 10 -o rsize"

#   my_ps: List processes owned by my user:
#   ------------------------------------------------------------
    my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }


#   ---------------------------
#   6.  NETWORKING
#   ---------------------------
    alias myip='curl ip.appspot.com'                    # myip:         Public facing IP Address
    alias netCons='lsof -i'                             # netCons:      Show all open TCP/IP sockets
    alias flushDNS='dscacheutil -flushcache'            # flushDNS:     Flush out the DNS Cache
    alias lsock='sudo /usr/sbin/lsof -i -P'             # lsock:        Display open sockets
    alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'   # lsockU:       Display only open UDP sockets
    alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'   # lsockT:       Display only open TCP sockets
    alias ipInfo0='ipconfig getpacket en0'              # ipInfo0:      Get info on connections for en0
    alias ipInfo1='ipconfig getpacket en1'              # ipInfo1:      Get info on connections for en1
    alias openPorts='sudo lsof -i | grep LISTEN'        # openPorts:    All listening connections
    alias showBlocked='sudo ipfw list'                  # showBlocked:  All ipfw rules inc/ blocked IPs

#   ii:  display useful host related informaton
#   -------------------------------------------------------------------
    ii() {
        echo -e "\nYou are logged on ${GREEN}$HOSTNAME${NOCOLOR}"
        echo -e "\nAdditionnal information:$NOCOLOR " ; uname -a
        echo -e "\n${RED}Users logged on:$NOCOLOR " ; w -h
        echo -e "\n${RED}Current date :$NOCOLOR " ; date
        echo -e "\n${RED}Machine stats :$NOCOLOR " ; uptime
        echo -e "\n${RED}Current network location :$NOCOLOR " ; scselect
        echo -e "\n${RED}Public facing IP Address :$NOCOLOR " ;myip
        #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
        echo
    }

#   ---------------------------------------
#   7.  SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------
    alias mountReadWrite='/sbin/mount -uw /'    # mountReadWrite:   For use when booted into single-user

#   generate an SSH Key
#   -------------------------------------------------------------------
    function sshKeyGen(){

        echo "What's the name of the Key (no spaced please) ? ";
        read name;

        echo "What's the email associated with it? ";
        read email;

        `ssh-keygen -t rsa -f ~/.ssh/id_rsa_$name -C "$email"`;
        pbcopy < ~/.ssh/id_rsa_$name.pub;

        echo "SSH Key copied in your clipboard";

    }

#  Generates a tree view from the current directory
#   -------------------------------------------------------------------
    function tree(){
        pwd
        ls -R | grep ":$" |   \
        sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
    }

#   cleanupDS:  Recursively delete .DS_Store files
#   -------------------------------------------------------------------
    alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

#   finderShowHidden:   Show hidden files in Finder
#   finderHideHidden:   Hide hidden files in Finder
#   -------------------------------------------------------------------
    alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
    alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'

#   cleanupLS:  Clean up LaunchServices to remove duplicates in the "Open With" menu
#   -----------------------------------------------------------------------------------
    alias cleanupLS="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

#    screensaverDesktop: Run a screensaver on the Desktop
#   -----------------------------------------------------------------------------------
    alias screensaverDesktop='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'

#   ---------------------------------------
#   8.  WEB DEVELOPMENT
#   ---------------------------------------
    alias apacheEdit='sudo edit /etc/httpd/httpd.conf'      # apacheEdit:       Edit httpd.conf
    alias apacheRestart='sudo apachectl graceful'           # apacheRestart:    Restart Apache
    alias editHosts='sudo edit /etc/hosts'                  # editHosts:        Edit /etc/hosts file
    alias herr='tail /var/log/httpd/error_log'              # herr:             Tails HTTP error logs
    alias apacheLogs="less +F /var/log/apache2/error_log"   # Apachelogs:   Shows apache error logs
    httpHeaders () { /usr/bin/curl -I -L $@ ; }             # httpHeaders:      Grabs headers from web page

#   httpDebug:  Download a web page and show info on what took time
#   -------------------------------------------------------------------
    httpDebug () { /usr/bin/curl $@ -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n" ; }

#   Serve current directory tree at http://$HOSTNAME:8080/
#   -------------------------------------------------------------------
    webshare () {
        echo Web server started...
        echo http://$HOSTNAME:8080
        echo Press CTRL+C to stop sharing.
        python -m SimpleHTTPServer 8080
    }

#   ---------------------------------------
#   9.  GIT
#   ---------------------------------------

#   git completion helper to autocomplete git commands
#   ---------------------------------------
    source .git_completion.bash

#   ---------------------------------------
#   10.  NODE & PACKAGES
#   ---------------------------------------

#   List globally installed npm packages
#   -------------------------------------------------------------------
    npmls() {
        npm ls -gp | awk -F/ '/node_modules/ && !/node_modules.*node_modules/ {print $NF}'
    }

#   Get updates installed Ruby gems, Homebrew, npm, and their installed packages
#   -------------------------------------------------------------------
    alias update='brew doctor; brew update; brew upgrade --all; brew cask cleanup; brew cleanup; npm update -g; gem update --system; gem update'
