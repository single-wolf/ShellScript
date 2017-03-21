##
# Author: kingcc<laikinfox@gmail.com>
# Date  : 2016/10/1
##

#!/bin/bash

###Redesign for myself :)

DIR="$( cd "$( dirname "$0"  )" && pwd  )"
PRO="$DIR/GreenGraphrun.sh"
LOG="/home/zmvps/git.log"
CMD="00 00 * * * $PRO>>$LOG 2>&1 &"
echo "$CMD"
cd $DIR
eval "$(ssh-agent -s)"
ssh-add
commits=$(($RANDOM%20+1))
i=0
while(($i<$commits))
do
commitTimesp=`sed -n '/run/p' ./README.md`
commitTimesh=${commitTimesp#*run }
commitTimes=${commitTimesh% times.}
sed -i "s/$commitTimes/$(($commitTimes+1))/" ./README.md
git add -A && git commit -m "$(($commitTimes+1))"
i=$(($i+1))
done
git push origin master
(crontab -l 2>/dev/null | grep -Fv $PRO; echo "$CMD") | crontab -
sudo pkill -8 ssh-agent
cd ~
