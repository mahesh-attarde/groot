#!/bin/bash
export CTX_LLC=$(which llc)
export CTX_GDB=$(which gdb)
######################## LLC LOG ANCHORING ##############################



# Function to replace strings with prefix
make_llc_debug_anchor() {
    local search_string="$2"
    local file="$1"

    # Perform in-place replacement
    sed -i "s|$search_string|#Dump $search_string|g" "$file"
}

# Iterate over the array and call the function
preprocess_llc_debug() {
# Define the array of strings
strings=("Initial selection DAG:"
         "Optimized lowered selection DAG:"
         "Type-legalized selection DAG:"
         "Optimized type-legalized selection DAG:"
         "Legalized selection DAG:"
         "Optimized legalized selection DAG:"
         "Selected selection DAG:")
for str in "${strings[@]}"; do
    make_llc_debug_anchor "$1" "$str"
done
}

#########################################################################
# Make Debug Log with Anchors
llc_log(){
    llc --debug $@ 2>&1 | tee llc.log
    preprocess_llc_debug llc.log
}

# llvm/utils/gdb-scripts/prettyprinters.py
dllc(){
    if  [ -f "bk.pt" ]; then
        $CTX_GDB  -q -x bk.pt --args llc $@
    else
        $CTX_GDB -q --args llc $@
    fi
}


############################### LLC - GISEL #####################################
gllc(){
  test=$1
  debug=$2
  if [[ $debug == "debug" ]]; then
    gdebug="--debug"
  else
    gdebug="--print-after=instruction-select --print-before=instruction-select"
  fi

  $MYLLVMBIN/llc -global-isel $gdebug $test  -o ${test}.g.s &> ${test}.g.log
  if [ $? -ne 0 ]; then
    echo "Error: Failed to execute llc with -global-isel"
    return 1
  fi

  if [[ $debug == "debug" ]]; then
    sdebug="--debug"
  else
    sdebug="--print-after=x86-isel --debug"
  fi

  $MYLLVMBIN/llc  $sdebug $test -o ${test}.d.s &> ${test}.d.log
  if [ $? -ne 0 ]; then
    echo "Error: Failed to execute llc with -DAG"
    return 1
  fi
  preprocess_llc_debug ${test}.d.log
}


### clang-ir work
clang_ir_linker(){
  echo   -Wl,-plugin-opt=-print-after-all -Wl,-plugin-opt=\"-filter-print-funcs=MyFunc\"
  echo   "gold linker : -Wl,-plugin-opt=save-temps"
  echo   "lld linker : -Wl,-mllvm,save-temps"
}


### Bug point
bgpt(){
  echo "https://logan.tw/posts/2014/11/26/llvm-bugpoint/"
  bugpoint  --compile-custom --compile-command=bgpt.sh 
}


### sde
sde_itrace(){
  sde64 -itrace_count 1 -- $@
  echo "Generated $PWD/sde-itrace-out.txt"
}

sde_mix(){
  sde64 -mix -mix_count_rep_iterations 0 -mix_omit_per_function_stats 1 -global_hot_blocks 0 -- $@
  echo "Generated $PWD/sde-mix-out.txt"
}