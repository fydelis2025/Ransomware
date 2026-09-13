all:
	nasm -f elf64 ransom_demo.asm -o ransom_demo.o
	ld ransom_demo.o -o ransom_demo
	nasm -f elf64 decrypt_demo.asm -o decrypt_demo.o
	ld decrypt_demo.o -o decrypt_demo

clean:
	rm -f *.o ransom_demo decrypt_demo
