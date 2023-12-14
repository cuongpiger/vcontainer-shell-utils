#!/bin/bash

########################################################################################################################
# Author: Cuong. Duong Manh <cuongdm8499@gmail.com>
# Description: This file contains some functions to check the input parameters
########################################################################################################################

# Check if the given string is empty or not
function isEmpty() {
  str=$(trimming "$1")
  if [ -z "$str" ] || [ "$str" == "null" ]; then
    # empty
    return 1
  else
    return 0
  fi
}

# Remove leading and trailing spaces
function trimming() {
  str=$(echo "$1" | xargs)
  echo "$str"
}