##
# Author: kingcc<laikinfox@gmail.com>
# Date  : 2016/10/1
##

#!/bin/bash

###Redesign for myself :)
cd ~/MyGit/ShellScript/
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
sudo pkill -8 ssh-agent
cd ~
