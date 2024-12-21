#!/bin/bash

shopt -s globstar
shopt -s nullglob
shopt -s nocaseglob

# Test an IP address for validity:
# Usage:
#      valid_ip IP_ADDRESS
#      if [[ $? -eq 0 ]]; then echo good; else echo bad; fi
#   OR
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
#
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


HELP=()
IP=()

for i in **/*
do
    if [ -f "$i" ]; then
        IP=$(egrep -a -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' "${i[@]}")
        for ip in ${IP}; do
#            if [ ${#ip} -eq 0 ]; then
#                echo "Empty"
#            else
#                 echo "Path is ${i[@]}"
                TEST="${ip} ${i[@]}"
                # echo ${TEST}
                # sleep 0.5
                HELP+=(${TEST})
#            fi
        done
    fi
done

for line in "${HELP[@]}"
do
    ip=$(echo $line | cut -f1 -d' ')

    test_empty=$(echo $ip | egrep -a -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}')
    if [ ${#test_empty} -eq 0 ]; then
        # echo "Not an IP"
        continue
    fi

    path=$(echo "$line" | cut -f2 -d' ')
    # echo $ip " " $path
    if valid_ip $ip; then
        IP+=(${ip})
    fi

    # echo ""

#    sleep 0.1
done

IP_sort=($(echo "${IP[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
for ip in "${IP_sort[@]}"
do
    echo ${ip}
done
