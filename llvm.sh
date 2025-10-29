#! /bin/bash

export DEV_REMOTE=https://github.com/mahesh-attarde/llvm-project.git
export LLVM_REMOTE=https://github.com/llvm/llvm-project.git
export MYTEMPDIR=/iusers/mattarde/temp

#########################################################
# SET WS FOR LLVM
llvmws(){
  export MYLLVMWS=$PWD
  export MYLLVMBIN=$MYLLVMWS/build/bin/
  export LLVMWSBIN=$MYLLVMBIN
  export LLVMWSWS=$MYLLVMWS/llvm
  export PATH=$MYLLVMBIN:$PATH
  mkdir -p $MYTEMPDIR
}

alias cdws='cd $MYLLVMWS'
alias cdll='cd ${MYLLVMWS}/llvm/'
alias cd86='cd ${MYLLVMWS}/llvm/lib/Target/X86/'

llvm_check_ws(){
    if [[ -z "${MYLLVMWS}" ]]; then
        echo 0
    fi
    echo 1
}
#########################################################

# Clone 
lvclone(){
 git clone  $LLVM_REMOTE $1
}

# Add Remote
lvaddremote(){
     git remote add upstream $DEV_REMOTE
}
# Sync Remote

# push branch to fork
lvpushbr(){
    git push -u upstream $1 
}
# Rebase
lvfr(){
    branch=main
    remote=upstream
    if [ -z "$1" ]; then
        echo "Fetch and Rebasing ${remote}/${branch}" 
    fi
    git fetch $remote && git rebase -i $remote/$branch
}

# We can only push to own forks
lvpf(){
    git push upstream $1 --force
}

#########################################################
# Compile 
lvconfig() {
    config_name=${1:-"default"} 
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi 
    config_file="$GROOT/build_config/$config_name"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        echo "Configuration file not found: $config_file"
        echo "Available configurations:"
        if [[ -d "$GROOT/build_config" ]]; then
            ls "$GROOT/build_config/"
        else
            echo "  $GROOT/build_config directory does not exist"
        fi
        return
    fi
    
    echo "Configuring LLVM with config: $config_name"
    echo "Using config file: $config_file"
    
    # Read configuration options from file
    EXTRA_CONF=""
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            EXTRA_CONF="$EXTRA_CONF $line"
        fi
    done < "$config_file"
    
    cd $MYLLVMWS
    mkdir -p build 
    cd build
    
    # Execute cmake with base configuration plus config file options
    echo cmake $EXTRA_CONF
    eval "cmake $EXTRA_CONF"
}

lvb() {
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    echo "Building LLVM..."
    cd $MYLLVMWS/build
    ninja
}

lvcc() {
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    cd $MYLLVMWS/build
    ninja check-clang
}

lvcl() {
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    cd $MYLLVMWS/build
    ninja check-llvm
}

lvmkclean() {
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    cd $MYLLVMWS/build
    ninja clean
}
# Testing
llit() {
    test_prefix=$1
    options=$2    
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    $LLVMWSBIN/llvm-lit $MYLLVMWS/llvm/test/${test_prefix} $options &> $MYTEMPDIR/llit.log
    code $MYTEMPDIR/llit.log
}

clit() {
    test_prefix=$1
    options=$2    
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    $LLVMWSBIN/llvm-lit $MYLLVMWS/clang/test/${test_prefix} $options &> $MYTEMPDIR/clit.log
    code $MYTEMPDIR/clit.log
}

lvformat() {
 $MYLLVMWS/clang/tools/clang-format/git-clang-format --binary=$MYLLVMBIN/clang-format HEAD
}

# Update Test
update_llc() {
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    
    if [ -f "$MYLLVMBIN/llc" ]; then
        export LLC=$MYLLVMBIN/llc
        echo "Using LLC binary: ${LLC}"
        
        # Check if arguments are provided
        if [ $# -eq 0 ]; then
            echo "No files provided. Usage: update_llc file1.ll file2.ll ..."
            return
        fi
        
        # Process each argument
        for file in "$@"; do
            # Check if file exists
            if [ ! -f "$file" ]; then
                echo "File not found: $file"
                continue
            fi
            
            # Check if file has .ll extension
            if [[ "$file" != *.ll ]]; then
                echo "Skipping non-IR file: $file"
                continue
            fi
            
            echo "Updating $file..."
            $MYLLVMWS/llvm/utils/update_llc_test_checks.py --llc-binary $LLC "$file"
        done
    else
        echo "Not Valid llc binary! $MYLLVMBIN/llc not found."
    fi      
}

