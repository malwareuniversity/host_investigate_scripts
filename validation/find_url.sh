#!/bin/bash

shopt -s globstar
shopt -s nullglob
shopt -s nocaseglob

HELP=()

for i in **/*
do
    if [ -f "$i" ]; then
        URL=$(egrep -a -o 'https?://[^ ]+' "${i[@]}")
        for url in ${URL}; do
#            if [ ${#url} -eq 0 ]; then
#                echo "Empty"
#            else
#                 echo "Path is ${i[@]}"
                TEST="${url} ${i[@]}"
                echo ${TEST}
                sleep 0.5
                HELP+=(${TEST})
#            fi
        done
    fi
done

for line in "${HELP[@]}"
do
    url=$(echo $line | cut -f1 -d' ')

    test_empty=$(echo $url | egrep -a -o 'https?://[^ ]+')
    if [ ${#test_empty} -eq 0 ]; then
        echo "Not a URL"
        continue
    fi

    path=$(echo "$line" | cut -f2 -d' ')
    echo $url " " $path

    echo ""

    sleep 0.1
done
