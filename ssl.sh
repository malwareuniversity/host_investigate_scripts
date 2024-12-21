#!/bin/bash

# To verify:
# openssl verify -verbose -x509_strict -CAfile ca.pem -CApath nosuchdir cert_chain.pem
CMD=$(echo | openssl s_client -showcerts -servername ${1} -connect ${1}:443 2>/dev/null | openssl x509 -inform pem -noout -text -checkend 0)
# We need to store all the root CAs and intermediate chains.
# EXPIRED=$(true | openssl s_client -connect ${1}:443 2>/dev/null | openssl x509 -noout -checkend 0)
# EXPIRED=$(openssl s_client -connect ${1}:443 2>/dev/null | openssl verify)
# echo ${EXPIRED}
# if  [[ ${EXPIRED} -ne 0 ]]; then
#    echo "SSL_WARN| SSL Certificate is expired!!!!"
#fi
ISSUER=$(echo "${CMD}" | grep -m 1 'Issuer' | cut -d':' -f 2-)

echo "SSL_ISSUER|${ISSUER}"
