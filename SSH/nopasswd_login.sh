#!/bin/bash

#try logging into remote-host without input password
#and reversing the ssh tunnel between local-host and remote-host


#local-host
#below is a simple ,you should change ruser(adviced not be root) ,remote-host and remote-port

#no passwd login setting
ssh-keygen -t rsa -P ""
if [ ! -f ~/.ssh/id_rsa.pub ];then
echo "Error to generate the host file"
exit 0
fi
ssh-copy-id -i ~/.ssh/id_rsa.pub ruser@remote-host

#reverse ssh tunnel
ssh ruser@remotessh -f -N -R remote-port:localhost:22 ruser@remote-host 
while true;do
RET=`ps aux | grep "ssh -f -N -R remote-port:localhost:22" | grep -v "grep"`
if [ "$RET" = "" ]; then
echo "restart ssh server"
ssh -f -N -R remote-port:localhost:22 ruser@remote-host
fi
sleep 10
done
#remote-host
#to ensure the file /home/ruser/.ssh/authorized_keys has right -rw-------(600)
#and the remote-port is avaliable

chmod 600 /home/ruser/.ssh/authorized_keys && ssh ruser@localhost -p remote-port
