#!  /bin/bash

# runutils_run_app_n_times ./code.o 50
runutils_run_app_n_times() {
  imax=$1
  cmd=$2
  for (( i=0; i<=$imax; i++ ))
  do
    echo "> Executing $i Run:$cmd"
    $cmd
  done
}

# runutils_run_app_on_all code.o
runutils_run_app_on_all() {
app=$1  
echo "Running $app on all files in $PWD"
for file in *; do
  if [ -f "$file" ]; then
    $app "$file"
  fi
done
}

# runutils_run_app_for_line_file code.o list.txt
runutils_run_app_for_line_file() {
app=$1
rfile=$2
for line in $(cat $rfile); do
  echo "Running $opts on each line in file $line"
  $app $line 
done
}

# runutils_foralldirs_cmd "ls -ltr | grep llvm &> log"
runutils_foralldirs_cmd()
{
for dir in */; do
    if [ -d "$dir" ]; then
        dirname="${dir%/}" 
        cd "$dir" || continue
        echo "$dirname"
        eval "$1"
        cd ..
    fi
done
}
