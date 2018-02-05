#!/bin/bash

# initialize filenames
FNAME=/monroe/results/neat_he
PMLOG=/monroe/results/neat_he.pm.log
METADATA=/monroe/results/neat_he.meta.json

# export NEAT library path
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/kau/neat/lib
export LD_LIBRARY_PATH

# store metadata (nodeid, modem and gps information)
cat /nodeid >> /monroe/results/nodenr
/opt/kau/metadata.py >> $METADATA 2>&1

# create working directories for NEAT
mkdir -p /var/run/neat/cib/
mkdir -p /var/run/neat/pib/

# if two interfaces are present, chose one for NEAT (coin toss)
IFs=`ls /sys/class/net/ | grep op`
IFss=( $IFs )

if [ ${#IFss[@]} -gt 1 ]
then
	coin=$(($RANDOM%2))
	if [ $coin -eq 0 ] 
	then
		cp /opt/kau/op0.profile /var/run/neat/pib/
	else
		cp /opt/kau/op1.profile /var/run/neat/pib/
	fi
else
	cp /opt/kau/op0.profile /var/run/neat/pib/
fi

# start NEAT Policy Manager
python3.5 /opt/kau/neat/policy/neatpmd --cib /var/run/neat/cib/ --pib /var/run/neat/pib/ >> $PMLOG 2>&1 &

# wait for Policy Manager to start and initialize
sleep 2

# Run experiment, pick either SCTP-TCP or TCP-SCTP (coin toss)
SERVER_IP=130.243.27.213
CMD_TCP="/usr/bin/neat_http_get -J -v 0 -P /opt/kau/tcp_first.policy $SERVER_IP"
CMD_SCTP="/usr/bin/neat_http_get -J -v 0 -P /opt/kau/sctp_first.policy $SERVER_IP"

coin=$(($RANDOM%2))
if [ $coin -eq 0 ] 
then
	${CMD_SCTP} 1>> ${FNAME}.sctp.json 2>> ${FNAME}.sctp.err
	${CMD_TCP} 1>> ${FNAME}.tcp.json 2>> ${FNAME}.tcp.err
else
	${CMD_TCP} 1>> ${FNAME}.tcp.json 2>> ${FNAME}.tcp.err
	${CMD_SCTP} 1>> ${FNAME}.sctp.json 2>> ${FNAME}.sctp.err
fi

exit 0
