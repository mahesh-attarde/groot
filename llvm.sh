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
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    EXTRA_CONF=""
    if [[ "$1" == "llvm-exegenis" ]]; then
      EXTRA_CONF=-DLLVM_ENABLE_LIBPFM=ON 
    fi
    echo "Configuring LLVM..."
    cd $MYLLVMWS
    mkdir -p build 
    cd build
    cmake -S ../llvm -G Ninja \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DBUILD_SHARED_LIBS=OFF \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_OPTIMIZED_TABLEGEN=OFF \
        $EXTRA_CONF \
        -DCMAKE_INSTALL_PREFIX=$PWD/install
        
}
lvconfig_sp(){
    env_set=$(llvm_check_ws)
    if [[ "$env_set" != "1" ]]; then
        echo "llvm-ws not set!"
        return
    fi
    echo "Configuring LLVM WITH SPECIAL..."
    cd $MYLLVMWS
    mkdir -p build 
    cd build
    cmake -S ../llvm -G Ninja \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DBUILD_SHARED_LIBS=OFF \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DCMAKE_BUILD_TYPE=Debug \
        -DLLVM_OPTIMIZED_TABLEGEN=OFF \
        -DLLVM_ENABLE_LIBPFM=ON  \
        -DCMAKE_INSTALL_PREFIX=$PWD/install
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
    $LLVMWSBIN/llvm-lit $LLVMWSWS/llvm/test/${test_prefix} $options &> $MYTEMPDIR/llit.log
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
    $LLVMWSBIN/llvm-lit $LLVMWSWS/clang/test/${test_prefix} $options &> $MYTEMPDIR/clit.log
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
        $MYLLVMWS/llvm/utils/update_llc_test_checks.py --llc-binary $LLC $1
        echo "Updating with ${LLC}"
    else
        echo "Not Valid $LLC llc binary!"
    fi      
}

