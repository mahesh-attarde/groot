#! /bin/bash

git clone https://git.code.sf.net/p/perfmon2/libpfm4 perfmon2-libpfm4
export P_LIBPFM4=$PWD/perfmon2-libpfm4
export LD_LIBRARY_PATH=$P_LIBPFM4/lib/:$LD_LIBRARY_PATH
export LIBRARY_PATH=$P_LIBPFM4/lib/:$LIBRARY_PATH
export C_INCLUDE_PATH=$P_LIBPFM4/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$P_LIBPFM4/include:$CPLUS_INCLUDE_PATH
echo "For LLVM, Configure with LLVM_ENABLE_LIBPFM=ON"
