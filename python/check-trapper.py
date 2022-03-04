#!/usr/bin/env python3

import json
import socket
import struct
import sys

sid = sys.argv[1]

packet = {'request': 'status.get',
                       'type': 'ping',
                       'sid': sid}

packet = str(json.dumps(packet)).encode('utf-8')
packet = b"ZBXD\1" + struct.pack('<Q', len(packet)) + packet
s = socket.socket()
try:
    s.connect(('127.0.0.1', int('10051')))
except Exception as e:
    print(e)
s.send(packet)
status = s.recv(1024).decode('latin-1')
print(status)
s.close()
