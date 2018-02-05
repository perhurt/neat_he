#!/usr/bin/python
# -*- coding: utf-8 -*-
from pprint import pprint
import multiprocessing
import time
import json
import zmq
import sys


def collect_data(output):
    context = zmq.Context()
    socket = context.socket(zmq.SUB)
    socket.connect('tcp://172.17.0.1:5556')
    socket.setsockopt(zmq.SUBSCRIBE, b'')
    grace = time.time() + 120

    while not (output['op0'] and output['op1'] and output['gps']):
        data = socket.recv()
        try:
            topic = data.split(" ", 1)[0]
            msg = json.loads(data.split(" ", 1)[1])
            if topic.startswith('MONROE.META.DEVICE.MODEM'):
                if msg['InternalInterface'] == 'op0':
                    output['op0'] = msg
                elif  msg['InternalInterface'] == 'op1':
                    output['op1'] = msg
            if topic.startswith('MONROE.META.DEVICE.GPS'):
                output['gps'] = msg
            if time.time() > grace:
                return
        except Exception as e:
            pass

if __name__ == '__main__':

    output = {}
    output['op0'] = False
    output['op1'] = False
    output['gps'] = False

    collect_data(output)

    print json.dumps(output)
