#!/bin/bash

if [ -e ${1} ]; then
    echo "You did not supply a domain"
    exit 1
fi

DOMAIN=${1}

DIG=$(dig +noall +answer ${DOMAIN})
ret=$?
if [[ ${ret} -ne 0 ]]; then
    echo "Error running dig on ${DOMAIN}"
    echo "${ret}"
    exit 2
fi
TYPE=$(echo ${DIG} | awk '{print $4}')
IP=$(echo ${DIG} | awk '{print $5}')

echo "${TYPE}|${IP}"
exit 0
