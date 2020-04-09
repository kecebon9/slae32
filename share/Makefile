# SLAE Exam Assignment: Makefile - helper script
# Author: Rikih Gunawan

TARGET=$(target)
TEST=shellcode
TEMPFILE:=$(shell mktemp -u --tmpdir=.)

all: build hex shellcode
clean-all: clean clean-shellcode

build: $(TARGET).o ## Compile the assembly code.
	@echo -e '\n[*] Linking object...'
	ld -m elf_i386 -o $(TARGET) $(TARGET).o
	@rm -f $(TARGET).o

$(TARGET).o: $(TARGET).nasm
	@echo -e '[*] Assembling with nasm...'
	nasm -f elf32 -o $(TARGET).o $(TARGET).nasm

disassemble: ## Run disassemble on compiled assembly.
	@echo -e '[*] Running disassemble $(TARGET)'
	objdump -d $(TARGET) -M intel

hex: ## Generate the opcode of compiled assembly.
	@echo -e '\n[*] Size of Shellcode:'
	@size $(TARGET)
	@echo -e '\n[*] Shellcode:'
	@objdump -d $(TARGET) | \
	grep -Po '\s\K[a-f0-9]{2}(?=\s)' | sed 's/^/\\x/g' | perl -pe 's/\r?\n//' | \
	sed 's/$$/\n/' | sed "s/^/\"/" | sed "s/$$/\"/g" > $(TARGET).txt
	@cat $(TARGET).txt
	@echo

check: ## Check null bytes on the shellcode.
	@echo -e '[*] Checking null bytes inside shellcode:\n'
	@if objdump -d $(TARGET) -M intel | grep 00; then \
		echo "[-] FAILED: Null bytes Found!"; \
	else \
		echo "[+] OK: No Null bytes found!"; \
	fi
	@echo

run: ## Run the compiled assembly.
	@echo -e '[*] Running $(TARGET)...'
	./$(TARGET)

debug: ## Run debugging on the compiled assembly.
	@echo -e '[*] Debugging $(TARGET)...'
	gdb -q ./${TARGET}

clean: ## Clean up the compiled assembly.
	@echo -e '[*] Cleanup $(TARGET).*'
	rm -f $(TARGET).txt
	rm -f $(TARGET).o
	rm -f $(TARGET)

#build-shellcode: $(TEST) tmp 

tmp:
	@cat $(TARGET).txt | sed 's|\\|\\\\|g' > tmp.txt

$(TEST): $(TARGET).txt skel.c tmp
	@echo -e '[*] Compiling shellcode...'
	@cp -f skel.c $(TEMPFILE).c
	@sed 's/CODE/$(shell cat tmp.txt)/' $(TEMPFILE).c > $(TEST).c
	@rm -f $(TEST)
	gcc -fno-stack-protector -z execstack $(TEST).c -o $(TEST)
	@rm -f tmp.txt
	@rm -f $(TEST).c
	@rm -f $(TEMPFILE).c
	@echo

run-shellcode: ## Run the shellcode.
	@echo -e '[*] Running $(TEST)...'
	./$(TEST)

debug-shellcode: ## Debug the shellcode.
	@echo -e '[*] Debugging $(TEST)...'
	gdb -q ./$(TEST)

clean-shellcode: ## Clean up the compiled shellcode.
	@echo -e '[*] Cleanup $(TEST).*'
	rm -f $(TEST)

help: ## Show this help.
	@echo -e '# Usage: make [option]\n'
	@echo -e '# option:'
	@fgrep -h "##" Makefile | sed -e 's/\(\:.*\#\#\)/\:\ /' | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s:
