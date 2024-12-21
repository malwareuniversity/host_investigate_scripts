#!/bin/bash

if [ -e ${1} ]; then
    echo "You did not supply a domain"
    exit 1
fi

DOMAIN=${1}
CMD=$(whois ${DOMAIN})

function HandleRIPE {
    # I wanted to make life hard on myself by echoing out the unformatted string.
    # We get to play with grep-based look ahead parsing to extract strings.
    # xargs will clean the output.
    # echo "INetNum|"$(echo ${CMD} | grep -o -P '(?<=inetnum:).*(?=netname:)' | xargs)
    echo "INetNum|"$(echo "${CMD}" | grep -m 1 'inetnum' | cut -d':' -f2- | xargs 2>/dev/null)
    echo "Country|"$(echo "${CMD}" | grep -m 1 'country' | cut -d':' -f2- | xargs 2>/dev/null)
    echo "OrgName|"$(echo "${CMD}" | grep -m 1 'org-name' | cut -d':' -f2- | xargs 2>/dev/null)
    echo "Phone|"$(echo "${CMD}" | grep -m 1 'phone' | cut -d':' -f2- | xargs 2>/dev/null)
    Remarks=()
    # echo "${CMD}" | grep 'remarks' | while read -r line ; do
    while read line; do
        found=0
        fmt_line=$(echo "${line}" | cut -d':' -f2- | xargs 2>/dev/null)
        len_remarks=${#Remarks[@]}
        if [ ${len_remarks} -eq 0 ]; then
            Remarks+=("${fmt_line}") 
            # echo "Remarks|${fmt_line}"
        else
            for i in "${Remarks[@]}"; do 
                echo "$i" | grep "${fmt_line}" 2>&1 > /dev/null
                if [ $? -eq 0 ]; then 
                    # Remarks+=("${fmt_line}")
                    # echo "Remarks|${fmt_line}"
                    found=1
                fi
            done
            # BASH is not a real programming language.
            # Can't do [ ! ${found} ]
            # # true -eq false if [[ ${found} -eq false ]]; then
            if [ ${found} -eq 0 ]; then 
                Remarks+=("${fmt_line}")
            fi
        fi
    # done
    done < <(echo "${CMD}" | grep 'remarks')
    # Damned subshells, need to implement process substitution to redirect output from separate processes to keep
    # this variable alive.
    for i in "${Remarks[@]}"; do
        echo "Remarks|${i}"
    done
}

function HandleARIN {
    # I wanted to make life hard on myself by echoing out the unformatted string.
    # We get to play with grep-based look ahead parsing to extract strings.
    # xargs will clean the output.
    # echo "INetNum|"$(echo ${CMD} | grep -o -P '(?<=inetnum:).*(?=netname:)' | xargs)
    echo "INetNum|"$(echo "${CMD}" | grep -m 1 'NetRange' | cut -d':' -f2- | xargs 2>/dev/null)
    echo "Country|"$(echo "${CMD}" | grep -m 1 'Country' | cut -d':' -f2- | xargs 2>/dev/null)
    echo "OrgName|"$(echo "${CMD}" | grep -m 1 'OrgName' | cut -d':' -f2- | xargs 2>/dev/null)
    echo "Phone|"$(echo "${CMD}" | grep -m 1 'OrgAbusePhone' | cut -d':' -f2- | xargs 2>/dev/null)
    Remarks=()
    # echo "${CMD}" | grep 'remarks' | while read -r line ; do
    while read line; do
        found=0
        fmt_line=$(echo "${line}" | cut -d':' -f2- | xargs 2>/dev/null)
        len_remarks=${#Remarks[@]}
        if [ ${len_remarks} -eq 0 ]; then
            Remarks+=("${fmt_line}") 
            # echo "Remarks|${fmt_line}"
        else
            for i in "${Remarks[@]}"; do 
                echo "$i" | grep "${fmt_line}" 2>&1 > /dev/null
                if [ $? -eq 0 ]; then 
                    # Remarks+=("${fmt_line}")
                    # echo "Remarks|${fmt_line}"
                    found=1
                fi
            done
            # BASH is not a real programming language.
            # Can't do [ ! ${found} ]
            # # true -eq false if [[ ${found} -eq false ]]; then
            if [ ${found} -eq 0 ]; then 
                Remarks+=("${fmt_line}")
            fi
        fi
    # done
    done < <(echo "${CMD}" | grep 'remarks')
    # Damned subshells, need to implement process substitution to redirect output from separate processes to keep
    # this variable alive.
    for i in "${Remarks[@]}"; do
        echo "Remarks|${i}"
    done
}

#
# If we receive a RIPE query, the user supplied an IP.
# We also need to handle ARIN queries.
#
echo "${CMD}" | grep "RIPE" 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    HandleRIPE  
    exit 0
fi
echo "${CMD}" | grep "ARIN" 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    HandleARIN
    exit 0
fi

#
# Command xargs by itself removes the whitespace, amazing!
#
echo "Registrar|"$(echo "${CMD}" | grep -m 1 'Registrar URL' | cut -d':' -f2- | xargs 2>/dev/null)
echo "AbuseEmail|"$(echo "${CMD}" | grep -m 1 'Registrar Abuse Contact Email' | cut -d':' -f2 | xargs 2>/dev/null)
echo "AbusePhone|"$(echo "${CMD}" | grep -m 1 'Registrar Abuse Contact Phone' | cut -d':' -f2 | xargs 2>/dev/null)
# Two results are returned on some WHOIS in the field.  Only show the date, not time.
echo "CreationDate|"$(echo "${CMD}" | grep -m 1 'Creation Date' | cut -d':' -f2 | cut -d'T' -f1 | xargs 2>/dev/null)
