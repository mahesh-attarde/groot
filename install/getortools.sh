#! /bin/bash
cd $WSTOOL
git clone https://github.com/google/or-tools.git --depth=1
# BUILD ALL DEP with RELEASE Mode for C++ BUILD.
# https://github.com/google/or-tools/blob/stable/cmake/README.md
cd or-tools
cmake  -S. -B build -DBUILD_DEPS:BOOL=ON -DCMAKE_INSTALL_PREFIX=$WSTOOL/or-tools/install
cmake --build ./build -j 32
cmake --install build
echo "Use Installation: "
echo $WSTOOL/or-tools/install
