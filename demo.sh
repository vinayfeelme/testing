#!/bin/bash

# This script prints a greeting message.

echo "Hello, World!"
echo "Today is: $(date)"
echo "Your current working directory is: $(pwd)"

# A simple if-else statement
if [ -d "$1" ]; then
    echo "Directory $1 exists."
else
    echo "Directory $1 does not exist."
fi
