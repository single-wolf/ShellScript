#!/bin/bash

###################Remote_rsync####################

#To use the useful rsync

#You should change the value of Rempte_IP and the path

rsync -Pa -I --size-only --delete --timeout=300 Remote_IP:/home/ubuntu/back /backup

#To use the ftp

#You should change the value of Remote_IP,UserName,Password and also the path 

lftp -c "open Remote_IP;user UserName Password;set cache:enable false;set ftp:passive-mode false;set net:timeout 15;mirror -e -c /back /backup;"
