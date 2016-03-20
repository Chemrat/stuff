#!/bin/bash

for i in *.flac; do
    BASE=`basename "$i" .flac`
    flac -c -d "$i" | lame -q 0 -m s -cbr -b 320 - "$BASE.mp3"
done
