#!/bin/bash

IFS=$(echo -en "\n\b")

for i in $@
do
    echo Checking $i
    ( file --mime-type $i | grep png | grep image/jpeg ) && mv $i $(echo $i | sed s/png$/jpeg/)
done
