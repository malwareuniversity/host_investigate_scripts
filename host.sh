#!/bin/bash

if [ -e ${1} ]; then
    echo "You did not supply a domain"
    exit 1
fi


function DNS_Record_Enum() {
    local record_type=$1
    CMD=$(host -t ${record_type} ${DOMAIN})
    ret=$?
    
    if [[ ${ret} -ne 0 ]]; then
        echo "Error enumerating DNS record ${record_type} on ${DOMAIN}" >&2
        return 1
    fi

    if [[ "${CMD}" =~ "no ${record_type} record" ]]; then
        return 0
    fi

    while read -r line; do
        cur_line=$(echo ${line} | awk 'NF>1{ print(substr($NF, 1, length($NF) - 1)) }')
        RECORDS[$record_type]+=${record_type}"|"${cur_line}$'\n'
    done <<< "${CMD}" 

    return 0
}


DOMAIN=${1}
IPs=()
# Associative array to hold various DNS records.
declare -A RECORDS
# If an IP was provided.
IP=${1}
is_ip=false

CMD=$(host -t A ${DOMAIN})
ret=$?
if [[ ${ret} -ne 0 ]]; then
    if [[ "${CMD}" =~ "not found" ]]; then
        echo "Host (${DOMAIN}) not found"
        exit 99
    fi
fi

#
# ${CMD} should only have multiple lines if it was a domain supplied.
#
while read -r line; do
    if [[ "${line}" =~ "domain name pointer" ]]; then
        # Grab PTR
        is_ip=true
        # Remove the trailing '.' from the domain record.
        DOMAIN=$(echo ${line} | awk '{print substr($5, 1, length($5) - 1)}')
        break
    elif [[ "${line}" =~ "${DOMAIN} has address" ]]; then
        is_ip=false
        cur_line=$(echo ${line} | awk '{print $4}')
        IPs+=(${cur_line})
    fi
done <<< "${CMD}"

# We could confirm the current resolving domain has IP in the IPs set by doing a:
# ping -c 1 ${DOMAIN} | gawk -F '[()]' '/PING/{print $2}'


if [ ${is_ip} = true ]; then
    echo ${DOMAIN}
    exit 0
fi

#
# If we get here we have a domain
#
for i in "${IPs[@]}"; do
    echo "A|${i}"
done

RECs=(CNAME MX NS)
for rec in "${RECs[@]}"; do
    DNS_Record_Enum ${rec}
done

for key in "${!RECORDS[@]}"; do
    # If there is any data in a record's type, print it.
    if [[ ${#RECORDS[${key}]} ]]; then
        for line in ${RECORDS[${key}]}; do
            echo ${line}
        done 
    fi
done
