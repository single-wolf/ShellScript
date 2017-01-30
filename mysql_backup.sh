#!/bin/bash

############### MySQL Backup ################

#You should to change the following vars

path=~/backup
refreshday="7"
dbname=""
user=root
Now=$(date +"%d-%m-%Y")

#To create the  directory

if [ -d ${path} ];then
echo "The backup directory exist"
else
mkdir ${path} || echo "Failed to create backup directory" 
fi
cd ${path}

#To get which dbname you want backup,if you add var below ,this part can be deleted

if [ ${dbname}="" ];then
echo -n "Enter the database name which you want backup (not be null):"
read dbname &&test -z ${dbname} && echo "Error:Input null" && exit 1
fi

#The backup filename
file=bakmysql-${dbname}-${Now}.sql

#Do backup with mysqldump command

mysqldump -u${user} -p ${dbname} > ${file} \
&& echo "Your database backup successfully completed"

#To refresh the backup files

echo -n "To delete backup files created ${refreshday} days ago?(y/N):"
read -t 5 info
case ${info} in
Y|y|YES|yes)
SevenDays=$(date -d -7day  +"%d-%m-%Y")
test -f bakmysql-${dbname}-${SevenDays}.sql\
&&rm -rf bakmysql-${dbname}-${SevenDays}.sql\
&&echo "Successfully delete ${refreshday} days ago backup file"
;;
N|n|NO|no|*)
;;
esac
