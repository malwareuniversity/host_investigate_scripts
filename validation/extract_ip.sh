#!/bin/bash

LIST=()

while read LINE; do
        HTTP=$(echo $LINE | grep -aEo '\b(https?|ftp)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]')
        # echo $HTTP
        LIST+=($HTTP)
done < full_url_search_npp_dump.txt

echo "Count is ${#LIST[@]}"
sorted_unique_urls=($(echo "${LIST[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
url_count=${#sorted_unique_urls[@]}
echo "Count is ${url_count}"
for url in ${sorted_unique_urls[@]}; do
        echo $url
done
