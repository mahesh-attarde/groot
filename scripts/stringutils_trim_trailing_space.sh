#! /bin/bash
function trim_trailing_space() {
  if [[ $# -eq 0 ]]; then
    echo "$FUNCNAME will trim (in place) trailing spaces in the given file (remove unwanted spaces at end of lines)"
    echo "Usage :"
    echo "$FUNCNAME file"
    return
  fi
  local file=$1
  unamestr=$(uname)
  if [[ $unamestr == 'Darwin' ]]; then
    #specific case for Mac OSX
    sed -E -i ''  's/[[:space:]]*$//' $file
  else
    sed -i  's/[[:space:]]*$//' $file
  fi
}
