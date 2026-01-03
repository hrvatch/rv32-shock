#!/usr/bin/env python3
import sys

with open(sys.argv[1], "rb") as f:
    bindata = f.read()

# Pad to 4-byte boundary
while len(bindata) % 4 != 0:
    bindata += b'\x00'

for i in range(0, len(bindata), 4):
    w = bindata[i:i+4]
    print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]))
