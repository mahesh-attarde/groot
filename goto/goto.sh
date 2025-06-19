#! /bin/bash
# @author: Mahesh Attarde
# Example entry in bookmark file
# NAME1 /usr/mahesh/workspace visible
# NAME2 /usr/ hidden
# BUGGY /bug/bug/bug hidden

# Keep BUGGY Line in Bookmark file.
# Export MYED=code or vim 
# Export MYSCRIPTHOME=GROOT Repo
export MYSCRIPTHOME=$GROOT
export MYGOTOHOME=$MYSCRIPTHOME/goto/goto.d
################################################################################
export fbookmark_file=
export fglobal_bookmark_file=
export bookmark_file=
export global_bookmark_file=
export lbookmark_file=

################################################################################
info_goto(){
    echo "MYSCRIPTHOME: $MYSCRIPTHOME"
    echo "MYGOTOHOME: $MYGOTOHOME"
    echo "bookmark_file: $bookmark_file"
    echo "global_bookmark_file: $global_bookmark_file"
    echo "fbookmark_file: $fbookmark_file"
    echo "fglobal_bookmark_file: $fglobal_bookmark_file"
    echo "lbookmark_file: $lbookmark_file"
}

change_directory() {
    local to=$1
    todir=$(eval echo "${to}")
    if [[ -d "${todir}" ]]; then
        cd $todir
        echo "Changed directory to: ${PWD}"
    else
        echo "Error: Failed to change directory to '${todir}'."
    fi
}

open_editor() {
    local efile=$1
    fpath=$(eval echo "${efile}")
    if [[ -f "${fpath}" ]]; then
        $EDITOR "${fpath}"
        echo "Opening file ${efile}"
    else
        echo "Error: Failed to open '${efile}'."
    fi
}


###############################################################################

create_bookmark_file(){
    fname=$1
    if [[ ! -f $fname ]]; then
        echo "Creating bookmark file: $fname"
        echo "BUGGY /bug/bug/bug hidden" &> "$fname"
    fi
}

save_bookmark_file(){
    fname=$1
    bookmark=$2
    bname=$(basename "$bookmark")
    if [[ -f $fname ]]; then
        echo "Saving bookmark to file: $fname"
        if ! grep -q "^$bname $bookmark" "$fname"; then
            sed -i "$(( $(wc -l < "$fname") - 1 ))i$bname $bookmark visible" "$fname"
        else
            echo "Bookmark already exists in the file: $fname"
            return
        fi

    else
        echo "Error: Bookmark file '$fname' does not exist."
    fi
}

parse_bookmark_file() {
    local bookmark_file=$1
    local show_hidden=$2
    local result=()

    # Check if the bookmark file exists and is readable
    if [[ ! -f "$bookmark_file" ]]; then
        echo "Error: Bookmark file '$bookmark_file' does not exist."
        return 1
    elif [[ ! -r "$bookmark_file" ]]; then
        echo "Error: Bookmark file '$bookmark_file' is not readable."
        return 1
    fi

    # Read and process each line in the bookmark file
    while IFS= read -r line; do
        # Skip empty lines or lines starting with a comment
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Tokenize the line into name, path, and visibility
        local name=$(echo "$line" | awk '{print $1}')
        local path=$(echo "$line" | awk '{print $2}')
        local visibility=$(echo "$line" | awk '{print $3}')

        # Validate the number of fields
        local num_fields=$(echo "$line" | awk '{print NF}')
        if [[ $num_fields -ne 3 ]]; then
            echo "Error: Invalid line format in $bookmark_file. Expected 3 fields, found $num_fields."
            echo "Skipping line: $line"
            continue
        fi

        # Add to result if visibility is "visible" or if hidden is allowed
        if [[ $visibility == "visible" || ($visibility == "hidden" && $show_hidden == true) ]]; then
            result+=("$name $path")
        fi
    done < "$bookmark_file"

    # Return the result as a space-separated list
    echo "${result[@]}"
}

display_bookmark_file() {
    local names=("${!1}")
    local paths=("${!2}")
    for i in "${!paths[@]}"; do
        printf "%-3s %-20s %s\n" "$((i+1))" "${names[i]}" "${paths[i]}"
    done
}

# Function to set the context based on the provided option
ctx() {
    opt=$1
    if [[ $opt == "ics" ]]; then
        fbookmark_file="${MYGOTOHOME}/fics_bookmarks.txt"
    elif [[ $opt == "llvm" ]]; then
        fbookmark_file="${MYGOTOHOME}/fllvm_bookmarks.txt"
    fi
    fglobal_bookmark_file="${MYGOTOHOME}/fuser_bookmarks.txt"

    if [[ $opt == "ics" ]]; then
        bookmark_file="${MYGOTOHOME}/ics_bookmarks.txt"
    elif [[ $opt == "llvm" ]]; then
        bookmark_file="${MYGOTOHOME}/llvm_bookmarks.txt"
    else
        echo "Warning: General Context! Please use 'ics' or 'llvm'."
    fi
    global_bookmark_file="${MYGOTOHOME}/user_bookmarks.txt"
}

goto_dir() {
    bkfile=$1
    gbkfile=$2
    opt=$3
    name=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | awk '{print $2}')
    visibility=$(echo "$line" | awk '{print $3}')

    show_hidden=false
    if [[ $opt == "-h" ]]; then
        show_hidden=true
    fi
    local paths=()
    paths=$(parse_bookmark_file $bkfile $show_hidden)
    gpaths=$(parse_bookmark_file $gbkfile $show_hidden)
    allpaths="$paths $gpaths"
    IFS=' ' read -r -a allpaths_array <<< "$allpaths"
    names=()
    paths=()
    for i in "${!allpaths_array[@]}"; do
        if (( i % 2 == 0 )); then
            names+=("${allpaths_array[i]}")
        else
            paths+=("${allpaths_array[i]}")
        fi
    done
    tput smcup
    display_bookmark_file names[@] paths[@]
    echo "Enter the number corresponding to the path you want to switch to: "
    read user_input
    if ! [[ $user_input =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid input. Please enter a numerical value."
        tput rmcup
        return
    fi
    tput rmcup
    user_input=$((user_input - 1))
    change_directory "${paths[$user_input]}"
}


goto_file() {
    bkfile=$1
    gbkfile=$2
    opt=$3
    name=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | awk '{print $2}')
    visibility=$(echo "$line" | awk '{print $3}')

    show_hidden=false
    if [[ $opt == "-h" ]]; then
        show_hidden=true
    fi
    local paths=()
    paths=$(parse_bookmark_file $bkfile $show_hidden)
    gpaths=$(parse_bookmark_file $gbkfile $show_hidden)
    allpaths="$paths $gpaths"
    IFS=' ' read -r -a allpaths_array <<< "$allpaths"
    names=()
    paths=()
    for i in "${!allpaths_array[@]}"; do
        if (( i % 2 == 0 )); then
            names+=("${allpaths_array[i]}")
        else
            paths+=("${allpaths_array[i]}")
        fi
    done
    tput smcup
    display_bookmark_file names[@] paths[@]
    echo "Enter the number corresponding to the path you want to switch to: "
    read user_input
    if ! [[ $user_input =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid input. Please enter a numerical value."
        tput rmcup
        return
    fi
    tput rmcup
    user_input=$((user_input - 1))
    open_editor "${paths[$user_input]}"
}


###################### CALLABLE FUNCTIONS ######################
igt(){
    info_goto
}

gtd(){
    goto_dir $bookmark_file $global_bookmark_file $1
}

gtf(){
    goto_file $fbookmark_file $fglobal_bookmark_file $1
}

cgt(){
    opt=$1
    if [[ $opt == "i" ]]; then
        lbookmark_file="${PWD}/bookmarks.txt"
        if [[ ! -f $lbookmark_file ]]; then
           create_bookmark_file $lbookmark_file
        fi 
    elif [[ $opt == "s" ]]; then
        save_bookmark_file $lbookmark_file $2
    elif [[ $opt == "d" ]]; then
        goto_dir $lbookmark_file $global_bookmark_file $2
    elif [[ $opt == "f" ]]; then
        goto_file $lbookmark_file $global_bookmark_file $2
    elif [[ $opt == "h" ]]; then
        echo "Usage: cgt i | s <bookmark> | p"
        echo "  i : Initialize bookmark file"
        echo "  s : Save bookmark to file"
        echo "  d : Change directory to bookmark"
        echo "  f : Open file in editor"
        echo "  p : Print current bookmark file"
    else
        echo "Invalid option."
    fi
    
}