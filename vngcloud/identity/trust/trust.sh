#!/bin/bash


#################################################### IMPORT MODULES ####################################################
# Import checker module
. $VCON_BASE_DIR/utils/checker.sh

################################################ SETUP DEFAULT VARIABLES ###############################################
# Number of retries for HTTP requests, default 5
VCONUTILS_HTTP_RETRY=${VCONTAINER_UTILS_HTTP_RETRY:-5}

# Delay between retries for HTTP requests, default 30 seconds
VCONUTILS_HTTP_RETRY_DELAY=${VCONTAINER_UTILS_HTTP_RETRY_DELAY:-10}

function getToken() {
  local username=$1
  local password=$2
  local identityDomain=$3

  if [ $(isEmpty "$username") -eq "1" ] || [ $(isEmpty "$password") -eq "1" ] || [ $(isEmpty "$identityDomain") -eq "1" ]; then
    echo "ERROR: The username, password and identity domain must be provided"
    exit 1
  fi

  local authURL="${identityDomain}/auth/tokens"
  local reqBody=$(_genGetTokenRequestBody "$username" "$password")
  local headers="Content-Type: application/json"
  local verifyCA=$( [ "$VERIFY_CA" == "True" ] && echo "-k" )
  local cmd="curl $verifyCA -s -i -X POST -H '"$headers"' -d '"$reqBody"' $authURL"

  i=0
  while [ $i -lt $VCONUTILS_HTTP_RETRY ]; do
    echo "INFO: Trying to get token from $authURL"
    echo "INFO: $cmd"
    response=$($cmd)
    echo "INFO: Response: $response"
    if [ $(echo "$response" | grep "HTTP/1.1 20" | wc -l) -eq 1 ]; then
      echo "INFO: Get token successfully"
      echo $(_extractTokenFromResponse "$response")
      break
    else
      echo "ERROR: Failed to get token"
      sleep $VCONUTILS_HTTP_RETRY_DELAY
      i=$((i + 1))
    fi
  done

  if [ $i -eq $VCONUTILS_HTTP_RETRY ]; then
    echo "ERROR: Failed to get token after $VCONUTILS_HTTP_RETRY retries"
    exit 1
  fi
}

function _extractTokenFromResponse() {
  local response=$1
  local token=$(echo "$response" | grep -i X-Subject-Token | awk '{print $2}' | tr -d '[[:space:]]')
  echo "$token"
}

function _genGetTokenRequestBody() {
  local trustID=$1
  local trustPassword=$2

  reqBody='
{
  "auth": {
    "identity": {
      "methods": [
        "password"
      ],
      "password": {
        "user": {
          "id": "'$trustID'",
          "password": "'$trustPassword'"
        }
      }
    }
  }
}'
  echo "$reqBody"
}

