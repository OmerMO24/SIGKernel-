AS = nasm
ASFLAGS = -f elf64
CC = clang
CFLAGS = --target=x86_64-elf -ffreestanding -nostdlib

all: kernel.bin
	 mv kernel.bin isofiles/boot
	 grub-mkrescue -o albert.iso isofiles

kernel.o: kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o 

boot.o: boot.s
	$(AS) $(ASFLAGS) boot.s

kernel.bin: kernel.o boot.o
	ld -nmagic -o kernel.bin -T linker.ld boot.o kernel.o 

clean:
	rm -f *.o *.bin *.iso
	rm -rf isofiles/boot/kernel.bin
