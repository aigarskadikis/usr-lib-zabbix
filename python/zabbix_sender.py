#!/usr/bin/env python3
### <PROTOCOL> - "ZBXD" (4 bytes).
### <FLAGS> - the protocol flags, (1 byte). 0x01 - Zabbix communications protocol, 0x02 - compression, 0x04 - large packet).
### <DATALEN> - data length (4 bytes or 8 bytes for large packet). 1 will be formatted as 01/00/00/00 (four bytes, 32 bit number in little-endian format) or 01/00/00/00/00/00/00/00 (eight bytes, 64 bit number in little-endian format) for large packet.
### <RESERVED> - uncompressed data length (4 bytes or 8 bytes for large packet). 1 will be formatted as 01/00/00/00 (four bytes, 32 bit number in little-endian format) or 01/00/00/00/00/00/00/00 (eight bytes, 64 bit number in little-endian format) for large packet.

### When compression is enabled (0x02 flag) the <RESERVED> bytes contains uncompressed data size.

### Zabbix protocol has 1GB packet size limit per connection. The limit of 1GB is applied for received packet data length and for uncompressed data length, however, when large packet is enabled (0x04 flag) it is possible for Zabbix proxy to receive configuration with size up to 16GB; note that large packet can only be used for Zabbix proxy configuration, and Zabbix server will automatically set (0x04 flag) and send length fields as 8 bytes each when data length before compression exceeds 4GB.

import socket
#import time
import struct
import json
from pprint import pprint

PROTOCOL=b'ZBXD'
FLAGS=1
RESERVED=b'\x00\x00\x00\x00'

zabbix_server="localhost"
#zabbix_server="127.0.0.1"
#zabbix_server="172.100.100.5"
zabbix_port=10051
#zabbix_port=16051
#msg = PROTOCOL + FLAGS.to_bytes(1,'little') +    datalen     + RESERVED + msg
#       ZBXD    +           0x01             + 01/00/00/00   + 01/00/00/00 + msg

class Package:
    def __init__(self,timestamp_enabled=False,nanoseconds_enabled=False):
        self.valuelist = []
        self.ts_enabled = timestamp_enabled
        self.ns_enabled = nanoseconds_enabled
    def add(self, host="trapper", key="trap", value=1):
        self.valuelist.append({'host': host, 'key': key, 'value': value})
    def prepare(self):
       return json.dumps({ 'request' : 'sender data', 'data' : self.valuelist })
    def generate(self, count):
        for i in range(1,count+1):
            self.add(value=i)
        return self.prepare()

def sizepretty(size,precision=2):
    suffixes=['B','KB','MB','GB','TB']
    suffixIndex = 0
    while size > 1024 and suffixIndex < 4:
        suffixIndex += 1 #increment the index of the suffix
        size = size/1024.0 #apply the division
    return "%.*f%s"%(precision,size,suffixes[suffixIndex])

while True:
    
    print('==================================================\n q : quit\n s [count]')
    count = 1
    data = input('input: ')
    if data == 'q':
        #s.close()
        break
    elif not data:
        #msg = b'{"request":"sender data","data":[{"host":"trapper","key":"trap","value":"hi"}]}'
        #ts = str(int(time.time()) + 3600)
        #data = '{"request":"sender data","data":[{"host":"trapper","key":"trap","value":1234,"clock":"'+ts+'"},{"host":"trapper","key":"trap","value":5678,"clock":"'+ts+'"}]}'
        p1 = Package()
        data = p1.generate(1)
        del p1
    elif "s" in data and data.strip(",.s ").isdigit():
        count = int(data.strip(",.s "))
        print(f"count: {count}")
        p1 = Package()
        data = p1.generate(count)
        del p1
    else:
        data = json.dumps({ 'request' : 'sender data', 'data' : [{"host":"trapper","key":"trap","value":data}] })
        pprint(data)
        
    msg = data.encode('utf8')
    del data
    datalen = len(msg)
    print(f"\033[34mData length: {sizepretty(datalen)}\033[39m")
    #sendornot = input("send y/n")
    if input("y/n") == 'y':
        datalen = struct.pack('i',datalen)
        msg = PROTOCOL + FLAGS.to_bytes(1,'little') + datalen + RESERVED + msg

        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            print(f"STATUS aftert SOCKET: {s}")
            s.connect((zabbix_server, zabbix_port))
            #with context.wrap_socket(s, server_side=False)
            print(f"STATUS after CONNECT: {s}")
            s.sendall(msg)
            print(f"STATUS after SENDALL: {s}")
            response = s.recv(1024)
            print(f"response: \033[32m{response}\033[39m\nSTATUS after RECV: {s}")
            #s.close()
        print(f"STATUS after CLOSE: {s}")
    else:
        pass

