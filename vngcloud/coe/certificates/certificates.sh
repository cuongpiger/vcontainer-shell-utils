#!/bin/bash

#################################################### IMPORT MODULES ####################################################
# Import checker module
. $VCON_BASE_DIR/utils/checker.sh
. $VCON_BASE_DIR/utils/logs.sh

################################################ SETUP DEFAULT VARIABLES ###############################################
# Number of retries for HTTP requests, default 5
VCONUTILS_HTTP_RETRY=${VCONUTILS_HTTP_RETRY:-5}

# Delay between retries for HTTP requests, default 10 seconds
VCONUTILS_HTTP_RETRY_DELAY=${VCONUTILS_HTTP_RETRY_DELAY:-10}

#################################################### FUNCTION LIST #####################################################

# Show detail about the CA certificate for a cluster
function getCACertificate() {
  local accessToken="$1"
  local coeDomain="$2"
  local clusterUUID="$3"

  if [ $(isEmpty "$accessToken") -eq "1" ] || [ $(isEmpty "$coeDomain") -eq "1" ] || [ $(isEmpty "$clusterUUID") -eq "1" ]; then
    log_error "The accessToken, coeDomain and cluster UUID must be provided"
    exit 1
  fi

  local certificateURL="${coeDomain}/certificates/${clusterUUID}"
  local authHeader="X-Auth-Token: $accessToken"
  local contentHeader="Content-Type: application/json"
  local verifyCA=$( [ "$VERIFY_CA" == "True" ] && echo "-k" )

  i=0
  while [ $i -lt $VCONUTILS_HTTP_RETRY ]; do
    log_info "Get certificates from $coeDomain"

    response=$(curl $verifyCA -X GET -H "$authHeader" -H "$contentHeader" $certificateURL)
    log_info "Response: $response"
    if [ $(echo "$response" | grep "HTTP/1.1 20" | wc -l) -eq 1 ]; then
      log_info "Get certificates successfully"
      echo $(_extractPemFromResponse "$response")
      break
    else
      log_error "Failed to get certificates, retry in $VCONUTILS_HTTP_RETRY_DELAY seconds"
      sleep $VCONUTILS_HTTP_RETRY_DELAY
      i=$((i + 1))
    fi
  done

  if [ $i -eq $VCONUTILS_HTTP_RETRY ]; then
    log_error "Failed to get certificates after $VCONUTILS_HTTP_RETRY retries"
    exit 1
  fi
}

# Generate certificates for clustwers
function generateCertificate() {
  local accessToken="$1"
  local certPath="$2"
  local coeDomain="$3"
  local clusterUUID="$4"

  if [ $(isEmpty "$accessToken") -eq "1" ] || [ $(isEmpty "$certPath") -eq "1" ] || [ $(isEmpty "$coeDomain") -eq "1" ] || [ $(isEmpty "$clusterUUID") -eq "1" ]; then
    log_error "The accessToken, certPath, coeDomain and cluster UUID must be provided"
    exit 1
  fi

  local certificateURL="${coeDomain}/certificates"
  local authHeader="X-Auth-Token: $accessToken"
  local contentHeader="Content-Type: application/json"
  local reqBody=$(_genUploadCertificateRequestBody "$certPath" "$clusterUUID")
  local verifyCA=$( [ "$VERIFY_CA" == "True" ] && echo "-k" )

  i=0
  while [ $i -lt $VCONUTILS_HTTP_RETRY ]; do
    log_info "Upload certificates to $coeDomain"

    response=$(curl $verifyCA -X POST -H "$authHeader" -H "$contentHeader" -d "$reqBody" $certificateURL)
    log_info "Response: $response"
    if [ $(echo "$response" | grep "HTTP/1.1 20" | wc -l) -eq 1 ]; then
      log_info "Upload certificates successfully"
      echo $(_extractPemFromResponse "$response")
      break
    else
      log_error "Failed to upload certificates, retry in $VCONUTILS_HTTP_RETRY_DELAY seconds"
      sleep $VCONUTILS_HTTP_RETRY_DELAY
      i=$((i + 1))
    fi
  done

  if [ $i -eq $VCONUTILS_HTTP_RETRY ]; then
    log_error "Failed to upload certificates after $VCONUTILS_HTTP_RETRY retries"
    exit 1
  fi
}

function _genUploadCertificateRequestBody() {
  local csr=$(cat "$1" | sed ':a;N;$!ba;s/\n/\\n/g')
  local clusterUUID="$2"

  reqBody='
{
  "cluster_uuid": "'$clusterUUID'",
  "csr": "'$csr'"
}'

  echo "$reqBody"
}

function _extractPemFromResponse() {
  local response=$1
  local pem=$(echo "$response" | jq -r '.pem')
  echo "$pem"
}
