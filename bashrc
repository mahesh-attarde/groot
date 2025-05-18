# For ENV 
source ${GROOT}/grootrc
# For Color and PS1
source ${GROOT}/color.sh
# For Binutils and other tools
source ${GROOT}/toolrc
# Set the default editor
export EDITOR=vim
export VISUAL=gvim
export MYED=code
alias g='gvim'

setvscode() {
    export PATH=${VSCODE_GIT_ASKPASS_NODE%/*}/bin/remote-cli:$PATH
}

# Editor
e()  { $MYED $1; }
el() { $MYED llvm/$1; }
ef() { find . -name $1 | xargs $MYED ;}
elf() { find llvm -name $1 | xargs $MYED; }
edif(){ $MYED --diff $1 $2; }
ezrpt(){ $MYED ./zperf_rt_rpt.log; }
efzrpt() { find . -name zperf_rt_rpt.log | xargs $MYED ;}
efb() { find . -name build.log | xargs $MYED ;}
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
                $MYED "$file"
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
alias scd='pushd $PWD'
alias ppd='popd'
#alias disasm="objdump -D --no-show-raw-insn --no-addresses"

# Search command line history
alias h="history | grep "
# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
# Search files in the current folder
alias f="find . | grep "
# Alias's to show disk space and space used in a folder
alias csize='du -h --max-depth=1 | sort -hr'
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Get Path
alias ff='find . -name'

mkcd() { mkdir -p "$@" && cd "$@"; }
gtp()  { readlink -f $1 ;}
ffgtp(){ find . -name $1 | xargs readlink -f ; }



## Source Other Scripts
alias edrc='source ${GROOT}/bashrc'
alias ldrc='source ${GROOT}/bashrc'
alias llrc='source ${GROOT}/llvm.sh'
alias icsrc='source ${GROOT}/izx.sh'
alias gtrc='source ${GROOT}/goto/goto.sh'
alias dbrc='source ${GROOT}/compiler_debug.sh'