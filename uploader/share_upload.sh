#!/bin/bash

# Config

server=example.com
serverpath=/home/user/uploads

# Uploader

curdate=`date +%F`
ssh $server "mkdir $serverpath/$curdate"
scp "$1" "$server:$serverpath/$curdate/$1"
xdg-open "https://$server/uploads/$curdate/$1"
