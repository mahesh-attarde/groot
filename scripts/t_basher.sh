#! /bin/bash

if [ -z "${VAR}" ]; then
    echo "VAR is unset or set to the empty string"
fi
if [ -z "${VAR+set}" ]; then
    echo "VAR is unset"
fi
if [ -z "${VAR-unset}" ]; then
    echo "VAR is set to the empty string"
fi
if [ -n "${VAR}" ]; then
    echo "VAR is set to a non-empty string"
fi
if [ -n "${VAR+set}" ]; then
    echo "VAR is set, possibly to the empty string"
fi
if [ -n "${VAR-unset}" ]; then
    echo "VAR is either unset or set to a non-empty string"
fi


###################################################
# LOOPS

echo "1. Looping Over a List of Values"
for item in apple banana cherry
do
    echo "Fruit: $item"
done

echo -e "\n2. Looping Over a Range of Numbers"
for i in {1..5}
do
    echo "Number: $i"
done

echo -e "\n3. Looping Over a Range of Numbers with a Step"
for i in {1..10..2}
do
    echo "Number: $i"
done

echo -e "\n4. Using C-style Syntax"
for ((i=1; i<=5; i++))
do
    echo "Number: $i"
done

echo -e "\n5. Looping Over the Output of a Command"
for file in $(ls)
do
    echo "File: $file"
done

echo -e "\n6. Looping Over Lines in a File"
while IFS= read -r line
do
    echo "Line: $line"
done < "file.txt"

echo -e "\n7. Looping Over Files in a Directory"
for file in /path/to/directory/*
do
    echo "File: $file"
done

echo -e "\n8. Looping Over Arguments Passed to the Script"
for arg in "$@"
do
    echo "Argument: $arg"
done

echo -e "\n9. Looping with a Break Condition"
for i in {1..10}
do
    if [ $i -eq 5 ]; then
        break
    fi
    echo "Number: $i"
done

echo -e "\n10. Looping with a Continue Condition"
for i in {1..5}
do
    if [ $i -eq 3 ]; then
        continue
    fi
    echo "Number: $i"
done

echo -e "\n11. Looping Over an Array"
arr=("apple" "banana" "cherry")
for item in "${arr[@]}"
do
    echo "Fruit: $item"
done

echo -e "\n12. Looping with a Command Substitution"
for user in $(cut -d: -f1 /etc/passwd)
do
    echo "User: $user"
done
