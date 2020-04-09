# Assigment #7 - Shellcode Crypter

- `aes_dec.go` : Shellcode decrpyter
- `aes_enc.go` : Shellcode crypter 

### To compile:
```
go build aes_enc.go
go build aes_dec.go
```

### To run:
```
# encrypter
./aes_enc deadbeefdeafface

# decrypter
execstack -s ./aes_dec.go deafb
./aes_dec deadbeefdeafface
```
