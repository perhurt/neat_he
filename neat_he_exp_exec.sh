#!/bin/bash

# initialize filenames
FNAME=/monroe/results/neat_he
METADATA=/monroe/results/neat_he.meta.json

# store metadata (nodeid, modem and gps information)
cat /nodeid >> /monroe/results/nodenr
/opt/kau/metadata.py >> $METADATA 2>&1

sleep 2

coin=$(($RANDOM%2))
if [ $coin -eq 0 ]
then
    python3.5 /opt/kau/http_client.py --proto sctp --stats 1>> ${FNAME}.sctp.json 2>> ${FNAME}.sctp.err
    python3.5 /opt/kau/http_client.py --proto tcp --stats 1>> ${FNAME}.tcp.json 2>> ${FNAME}.tcp.err
else
    python3.5 /opt/kau/http_client.py --proto tcp --stats 1>> ${FNAME}.tcp.json 2>> ${FNAME}.tcp.err
    python3.5 /opt/kau/http_client.py --proto sctp --stats 1>> ${FNAME}.sctp.json 2>> ${FNAME}.sctp.err
fi

exit 0
