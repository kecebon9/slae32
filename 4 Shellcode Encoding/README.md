# Assigment #4 - Shellcode Encoding

- `decoder.nasm` : Shellcode decoder asm
- `encoder.py` : Shellcode encoder python

### To run:
```
# Run the encoder
python encoder.py

# compile the decoder
make target=decoder

# run the decoder
make target=decoder run-shellcode
```