#!/bin/bash
# @(#) VT - Check if a resource is suspicious/malicious or not.
#

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq is required but not installed. Please install jq and try again."
  exit 1
fi

# Check if .config file exists
if [[ ! -f .config ]]; then
  echo "Error: .config file not found in the current directory."
  exit 1
fi

# Extract the API key from the .config file
API=$(jq -r '.api_key' .config)

# Validate the API key
if [[ -z "$API" || "$API" == "null" ]]; then
  echo "Error: API key not found in the .config file."
  exit 1
fi

# Validate the input argument
if [[ -z $1 ]]; then
  echo "You need to provide a domain"
  exit 1
fi

URL=$1

# Call the VirusTotal API
CMD=$(curl -sS --request GET --url "https://www.virustotal.com/vtapi/v2/url/report?apikey=${API}&resource=${URL}")
POSITIVES=$(($(echo "${CMD}" | jq '.positives // 0'))) # Default to 0 if the key is missing or null

# Check the results
if [ ${POSITIVES} -gt 0 ]; then
  echo "VT|POS"
else
  echo "VT|NEG"
fi