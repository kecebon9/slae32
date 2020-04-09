# Assigment #3 - Egg hunter

- `egghunter.c` : egg hunter poc C
- `access2.nasm` : egg hunter

## To compile:
```
make target=access2
gcc -fno-stack-protector -z execstack egghunter.c -o egghunter
```

### To run:
```
./egghunter
```