#!/bin/bash

. $VCON_BASE_DIR/utils/checker.sh

isEmpty null

# Using the result in an if condition
if [ $? -eq 1 ]; then
  echo "The parameter is empty."
else
  echo "The parameter is not empty."
fi