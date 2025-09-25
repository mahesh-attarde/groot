#! /bin/bash
# IMPORTANT ARG  $@ == DONT NOT REMOVE ==
# Assumption that O0 passes and higher optimization results in crash or hang.
clang -O2 -g -c  -std=c++20 kernel.cpp $@
