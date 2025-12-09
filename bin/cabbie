#! /bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 file1 [file2 ...] "
    exit 1
fi
file_args=()
for arg in "$@"; do
 file_args+=("$arg")
done
for ll_file in "${file_args[@]}"; do
    python3 $GROOT/pyscripts/cabbie.py "$ll_file"
    if [[ $? -ne 0 ]]; then
        echo "[CABBIE RUN FAIL]: $ll_file"
        exit 
    fi
done 
