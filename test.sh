#!/bin/bash


check_empty() {
    if [ -z "$1" ]; then
        return 1
    else
        return 0
    fi
}

# Example usage:
check_empty "$1"

# Using the result in an if condition
if [ $? -eq 1 ]; then
    echo "The parameter is empty."
else
    echo "The parameter is not empty."
fi