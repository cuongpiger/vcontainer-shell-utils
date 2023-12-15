#!/bin/bash

########################################################################################################################
# Author: Cuong. Duong Manh <cuongdm8499@gmail.com>
# Description: This file contains some functions to check the input parameters
########################################################################################################################

# Check if the given string is empty or not
# Params:
#   $1: string
# Return:
#   1 if empty, 0 if not empty
function isEmpty() {
  str=$(trimming "$1")
  if [ -z "$str" ] || [ "$str" == "null" ]; then
    echo "1"
  else
    echo "0"
  fi
}

# Remove leading and trailing spaces
# Params:
#   $1: string
# Return:
#   trimmed string
function trimming() {
  str=$(echo "$1" | xargs)
  echo "$str"
}