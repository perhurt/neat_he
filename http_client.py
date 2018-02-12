#!/usr/bin/python3

import socket
import argparse
from urllib.parse import urlparse
import time, datetime
import json

current_milli_time = lambda: int(round(time.time() * 1000))

def get_url(url, transport):
    url = urlparse(url)
    path = url.path
    if path == '':
        path = '/'
    host = url.netloc
    port = 80

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, transport)

    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.settimeout(2)
    try:
        s.connect((host, port))
    except:
        s.close()
        return 0, False, None, 0

    request_str = 'GET / HTTP/1.0\r\n\r\n'
    sent = s.send(request_str.encode())
    data = s.recv(1000000)
    s.shutdown(1)
    s.close()
    return len(data), True, data, sent



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Fetch web root with arbitrary transport.')
    parser.add_argument('--url', type=str, dest='url', default='130.243.27.213', help='IP address')
    parser.add_argument('--proto', type=str, dest='proto', default='tcp', help='transport to use')
    parser.add_argument('--runs', type=int, dest='runs', default=1, help='experimental runs')
    parser.add_argument("--stats", help="output experiment statistics", action="store_true")
    args = parser.parse_args()

    url = 'http://%s' % (args.url)
    proto = args.proto

    output = {}
    output['url'] = url
    output['protocol'] = proto
    output['date'] = str(datetime.datetime.now())

    runs = []

    for i in range(0, args.runs):
        before = current_milli_time()
        size, supported, _, sent = get_url(url, socket.getprotobyname(proto))
        after = current_milli_time()

        data = {}
        data['supported'] = supported
        data['bytes sent'] = sent
        data['bytes received'] = size
        data['time'] = after-before
        runs.append(data)

    output['runs'] = runs

    if args.stats:
        json_data = json.dumps(output)
        print(json_data)
