# NOT COMPLETE
#! /bin/bash

export WORKPATH=$PWD
git clone git@github.com:AliveToolkit/alive2.git --depth=1
cd alive2
mkdir dependencies
cd dependencies
wget https://github.com/skvadrik/re2c/releases/download/4.3/re2c-4.3.tar.xz
tar -xf re2c-4.3.tar.xz
mkdir build
cd build

cd $WORKPATH/alive2/dependencies
git clone https://github.com/Z3Prover/z3.git
cd z3
python scripts/mk_make.py --prefix=$WORKPATH/alive2/dependencies/z3/build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release ..
ninja


cd $WORKPATH/alive2
mkdir build
cd build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. -DZ3_INCLUDE_DIR==$WORKPATH/dependencies/z3/install/include -DZ3_LIBRARIES=$WORKPATH/dependencies/z3/lib/libz3.so
ninja
export PATH=$PATH:$WORKPATH
/localdisk2/mattarde/wstool/alive2/dependencies/z3/install
