#!/bin/bash

#===========  Useful commands ===========================

git config --global grep.extendRegexp true
git config --global grep.lineNumber true

alias setrepo='gh repo set-default'
alias gg='git grep'
alias gga='git grep --break --heading --line-number'
alias wd='python3 -m http.server -d $PWD'
alias ff='find . -name'
alias drf='gh pr create --draft'

#========================================================

# Global variable for project directory
PROJ=""

bllvm() {
  # Set PROJ to current directory
  PROJ=$(pwd)

  # Prompt the user for the build type at the beginning
  echo "Enter the build type (e.g., Deb, Rel):"
  read build_type

  # Validate build type early
  if [ "$build_type" != "Deb" ] && [ "$build_type" != "Rel" ]; then
    echo "Invalid build type specified. Please enter either 'Deb' or 'Rel'."
    return 1
  fi

  # Check if llvm-project directory already exists
  if [ -d "llvm-project" ]; then
    echo "llvm-project directory already exists. Skipping clone."
  else
    echo "Cloning llvm-project repository..."
    git clone https://github.com/JaydeepChauhan14/llvm-project.git
  fi

  mkdir -p Build
  cd Build

  # Run the appropriate cmake command based on build type
  if [ "$build_type" == "Deb" ]; then
    echo "Configuring Debug build..."
    cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILER=$(which clang) -DCMAKE_CXX_COMPILER=$(which clang++) -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_USE_SPLIT_DWARF=ON -DLLVM_ENABLE_ASSERTIONS=ON -DBUILD_SHARED_LIBS=On -DCMAKE_LINKER=lld ../llvm-project/llvm
  elif [ "$build_type" == "Rel" ]; then
    echo "Configuring Release build..."
    cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=$(which clang) -DCMAKE_CXX_COMPILER=$(which clang++) -DLLVM_ENABLE_ASSERTIONS=ON -DBUILD_SHARED_LIBS=On -DCMAKE_LINKER=lld ../llvm-project/llvm
  fi

  make -j128

  export BINDIR=$(readlink -f bin)
  echo "Setting up clang in PATH"
  export PATH=$BINDIR:$PATH
  echo "Clang path set up"

  # Return to project directory
  cd "$PROJ"
}

rllvm() {
  # Check if PROJ is set
  if [ -z "$PROJ" ]; then
    echo "PROJ variable not set. Please run bllvm first or set PROJ manually."
    return 1
  fi

  # Navigate to build directory
  if cd "$PROJ/Build" 2>/dev/null; then
    echo "Entered build directory: $(pwd)"
  else
    echo "No build directory present at $PROJ/Build"
    return 1
  fi

  # Execute the build command
  make -j128
  if [ $? -eq 0 ]; then
    echo "Build successful"
  else
    echo "Build failed"
    cd "$PROJ/llvm-project"
    return 1
  fi

  cd "$PROJ/llvm-project"
}

sllvm() {
  # Check if PROJ is set
  if [ -z "$PROJ" ]; then
    echo "PROJ variable not set. Please run bllvm first or set PROJ manually."
    return 1
  fi

  if cd "$PROJ/Build" 2>/dev/null; then
    echo "Entered build directory: $(pwd)"
  else
    echo "No build directory present at $PROJ/Build"
    return 1
  fi

  export BINDIR=$(readlink -f bin)
  echo "Setting up clang in PATH"
  export PATH=$BINDIR:$PATH
  echo "Clang path set up"

  # Return to the project directory
  cd "$PROJ"
}

cllvmall() {
  # Check if PROJ is set
  if [ -z "$PROJ" ]; then
    echo "PROJ variable not set. Please run bllvm first or set PROJ manually."
    return 1
  fi

  # Navigate to build directory
  if cd "$PROJ/Build" 2>/dev/null; then
    echo "Running check-all in: $(pwd)"
    make check-all -j128 2>&1 | tee "$PROJ/checkall.log"
    cd -
  else
    echo "No build directory present at $PROJ/Build"
    cd -
  fi
}

cclang() {
  # Check if PROJ is set
  if [ -z "$PROJ" ]; then
    echo "PROJ variable not set. Please run bllvm first or set PROJ manually."
    return 1
  fi

  # Navigate to build directory
  if cd "$PROJ/Build" 2>/dev/null; then
    echo "Running check-clang in: $(pwd)"
    make check-clang -j128 2>&1 | tee "$PROJ/checkclang.log"
    cd -
  else
    echo "No build directory present at $PROJ/Build"
    cd -
  fi
}

cllvm() {
  # Check if PROJ is set
  if [ -z "$PROJ" ]; then
    echo "PROJ variable not set. Please run bllvm first or set PROJ manually."
    return 1
  fi

  # Navigate to build directory
  if cd "$PROJ/Build" 2>/dev/null; then
    echo "Running check-llvm in: $(pwd)"
    make check-llvm -j128 2>&1 | tee "$PROJ/checkllvm.log"
    cd -
  else
    echo "No build directory present at $PROJ/Build"
    cd -
  fi
}

cformat() {
  # Check if PROJ is set
  if [ -z "$PROJ" ]; then
    echo "PROJ variable not set. Please run bllvm first or set PROJ manually."
    return 1
  fi

  # Check if clang-format binary exists
  if [ ! -f "$PROJ/Build/bin/clang-format" ]; then
    echo "clang-format binary not found at $PROJ/Build/bin/clang-format"
    echo "Please ensure LLVM is built with clang-format."
    return 1
  fi

  # Check if git-clang-format script exists
  if [ ! -f "$PROJ/llvm-project/clang/tools/clang-format/git-clang-format" ]; then
    echo "git-clang-format script not found at $PROJ/llvm-project/clang/tools/clang-format/git-clang-format"
    return 1
  fi

  echo "Running git-clang-format with binary: $PROJ/Build/bin/clang-format"
  "$PROJ/llvm-project/clang/tools/clang-format/git-clang-format" HEAD --binary="$PROJ/Build/bin/clang-format"
}

sproj() {
  # Function to manually set PROJ variable
  PROJ=$(pwd)
  echo "PROJ set to: $PROJ"
  sllvm
}

llvmcmd() {
  echo "Available commands:"
  echo "  bllvm         -> Build llvm source"
  echo "  rllvm         -> ReBuild llvm source"
  echo "  sllvm         -> Set build compiler"
  echo "  cllvmall      -> Run make check for check-all"
  echo "  cclang        -> Run make check for check-clang"
  echo "  cllvm         -> Run make check for check-llvm"
  echo "  cformat       -> Run git-clang-format with built clang-format binary"
  echo "  sproj         -> Set PROJ variable to current directory"
  echo ""
  echo "Current PROJ: ${PROJ:-'Not set'}"
}
