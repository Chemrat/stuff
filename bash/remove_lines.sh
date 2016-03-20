#!/bin/bash

# Remove lines mentioned in $2 from $1

grep -v -x -f $2 $1 | sort -h | sponge $1
