#!/bin/bash
#########################################################################
# File Name: secure.sh
# Author: single-wolf
# mail: root@mail.zmblog.org
# Created Time: Fri 02 Mar 2018 03:41:53 PM CST
#########################################################################

#Log file cleaned if send mail successfully
CheckLog="/home/user/backup/SysCheck.log"
mailReceiver="root@mail.zmblog.org"
#Mail subject
subject="Daily Check Summary Mail"
#Your IP that do not need to ban
exceptIP=("112.74.60.247","127.0.0.1")
mailThreshold=10
date=`date`
dateCut=${date:4:6}
echo "${date} [INFO-Secure.sh] Start Secure Check ******************">> $CheckLog

###Check the mail.log

echo "${date} [INFO-Mail] Summary of mail banned IPs">> $CheckLog
warningIP=`cat /var/log/mail.log /var/log/mail.log.1| \
	grep "${dateCut}"|grep -E "(lost connection after (AUTH|EHLO|RCPT|STARTTLS)|authentication failed)"|\
	grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"|\
	sort -n|uniq -c|tee -a ${CheckLog}|awk -v THRESHOLD=$mailThreshold '{if($1>THRESHOLD){print $2;}}'`
for ip in $warningIP;
do
	if [[ "${exceptIP[@]/$ip/}" = "${exceptIP[@]}" ]];then
		iptables -A INPUT -s $ip -j DROP
	fi
done
echo "">> $CheckLog

###rkhunter System Check

echo "${date} [INFO-rkhunter] Summary of rkhunter check">> $CheckLog
rkhunter -c --sk > /dev/null
location=`grep -n "System checks summary" /var/log/rkhunter.log`
tail -n +${location%%:*} /var/log/rkhunter.log >> ${CheckLog}
echo "">> $CheckLog

###System port & ps Check

echo "${date} [INFO-port&ps] Summary of port and ps">> $CheckLog
echo "">> $CheckLog
netstat -lntp >> $CheckLog
echo "">> $CheckLog
ps aux|tail -n +2|sort -nrk 4|head -15 >> $CheckLog
echo "">> $CheckLog
dstat -cdlmnpsy 1 5 >> $CheckLog
##Clean logfile if send mail successfully
mail -s "$subject" $mailReceiver < $CheckLog && > $CheckLog
