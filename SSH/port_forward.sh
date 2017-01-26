#! /bin/bash

#below is a simple ,you should change localport ,user ,ip and remoteport
#ensure that the service of ssh is startting on the remote pc

ssh -2 -N -f -L localport:localhost:22 user@ip remoteport
echo "To start the port forward with ssh tunnel!"
