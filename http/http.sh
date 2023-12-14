#!/bin/bash

# The directory path where you store this library, default /srv/vcontainer
VCON_BASE_DIR=${VCON_BASE_DIR:-"/srv/vcontainer"}

# Number of retries for HTTP requests, default 5
VCONUTILS_HTTP_RETRY=${VCONTAINER_UTILS_HTTP_RETRY:-5}

# Delay between retries for HTTP requests, default 30 seconds
VCONUTILS_HTTP_RETRY_DELAY=${VCONTAINER_UTILS_HTTP_RETRY_DELAY:-30}


# Include checker module
. $VCON_BASE_DIR/utils/checker.sh


function makeRequest() {
  method=$1
  url=$2
  headers=$3
  expectedStatusCode=$4
  body=$5
  options=$6

  case $x in
  "GET")
    _makeGetRequest $url $headers $expectedStatusCode $options
    ;;
  esac

}

function _makeGetRequest() {
  url=$1
  headers=$2
  expectedStatusCode=$3
  options=$4

  cmd="curl ${options} -X GET"
  if [ -n "$headers" ]; then
    cmd="$cmd -H $headers"
  fi

  # check url is empty or not, return 1 if empty
  if [ -z "$url" ]; then
    return 1
  fi



  curl -X GET $url -H $headers -d $body
}
