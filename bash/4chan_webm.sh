#!/bin/bash

ffmpeg -i $1 -c:v libvpx -an $1.webm
