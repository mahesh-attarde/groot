# Set the default editor
export EDITOR=vim
export VISUAL=gvim
alias g='gvim'

# Editor
e()  { code $1; }
el() { code llvm/$1; }
ef() { find . -name $1 | xargs code ;}
elf() { find llvm -name $1 | xargs code; }
edif(){ code --diff $1 $2; }
ezrpt(){ code ./zperf_rt_rpt.log; }
efzrpt() { find . -name zperf_rt_rpt.log | xargs code ;}

ezlf(){
    find_and_edcode lf
}

find_and_edcode() {
    # Save the current terminal state
    saved_state=$(stty -g)
    ext=$1
    # Ensure terminal state is restored on exit
    trap 'stty "$saved_state"' EXIT

    files=($(find llvm -type f -name "*.${ext}"))
    if [ ${#files[@]} -eq 0 ]; then
        echo "No .${ext} files found in the llvm directory."
        return
    fi

    echo "Select a file to open:"
    select file in "${files[@]}"; do
        if [ -n "$file" ]; then
            read -p "You selected '$file'. Press Enter to open or type 'n' to abort: " confirm
            if [ "$confirm" != "n" ]; then
                code "$file"
            else
                echo "Operation canceled."
            fi
            return
        else
            echo "Invalid selection. Please try again."
        fi
    done

    # Restore the terminal state explicitly (in case trap didn't trigger)
    stty "$saved_state"
}




# Change dir
alias home='cd ~'
alias cd1='cd ..'
alias cd2='cd ../..'
alias cd3='cd ../../..'
alias cd4='cd ../../../..'
alias cd5='cd ../../../../..'
alias cd6='cd ../../../../../..'
alias cd7='cd ../../../../../../..'
alias cd8='cd ../../../../../../../..'
alias cdws='cd /iusers/mattarde'

# listing
alias la='ls -Alh' # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias ll='ls -Fls' # long listing format
alias labc='ls -lap' #alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only

# 
alias disasm="objdump -D --no-show-raw-insn --no-addresses"
alias scd='pushd $PWD'

# Search command line history
alias h="history | grep "
# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
# Search files in the current folder
alias f="find . | grep "
# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Get Path
alias ff='find . -name'
gtp()  {   readlink -f $1 ;}
ffgtp(){ find . -name $1 | xargs readlink -f ; }