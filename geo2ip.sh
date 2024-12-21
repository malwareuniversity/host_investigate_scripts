#!/bin/bash

if [ -e $1 ]; then
    echo "You need to provide a domain"
    exit 1
fi

URL=$1
IPADDR=()
FIND_HOST=$(host ${URL} | grep 'address ' | awk '{print $4}')
while read -r ip_address; do
    IPADDR+=(${ip_address})    
done <<< "${FIND_HOST}"

for ip_address in "${IPADDR[@]}"
do
    GEO_CMD=$(curl -ks https://ipapi.co/${ip_address}/json/)
    city=$(echo ${GEO_CMD} | jq '.city')
    region=$(echo ${GEO_CMD} | jq '.region')
    region_code=$(echo ${GEO_CMD} | jq '.region_code')
    country=$(echo ${GEO_CMD} | jq '.country')
    country_name=$(echo ${GEO_CMD} | jq '.country_name')
    continent_code=$(echo ${GEO_CMD} | jq '.continent_code')
    postal=$(echo ${GEO_CMD} | jq '.postal')
    timezone=$(echo ${GEO_CMD} | jq '.timezone')
    org=$(echo ${GEO_CMD} | jq '.org')

    echo ""
    echo "[${URL}][${ip_address}]"
    echo "City|${city}"
    echo "Region|${region}"
    echo "RegionCode|${region_code}"
    echo "Country|${country}"
    echo "CountryName|${country_name}"
    echo "ContinentCode|${continent_code}"
    echo "Postal|${postal}"
    echo "Timezone|${timezone}"
    echo "Org|${org}"
    echo ""
done
