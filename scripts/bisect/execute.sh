 #! /bin/bash

 # Hang or Crash 
 clang -O2 -g -o kernel.exe   -std=c++20 kernel.o 
 # for Hang kill after say 5s, send signal SIGKILL (kill -l)
 timeout -k 9 5  ./kernel.exe 1

 
