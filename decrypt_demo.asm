; decrypt_demo.asm — DESCRIPTOGRAFIA (mesmo algoritmo XOR)
; Uso: ./decrypt_demo arquivo_teste.txt.locked
; Aplica XOR novamente (operação simétrica) e restaura o nome original
; PROJETO EDUCACIONAL — FydelisTech
global _start

section .data
    key         db 0x42, 0x13, 0x37, 0x99   ; MESMA chave do ransom_demo
    key_len     equ 4
    ext_locked  db ".locked"
    ext_len     equ 7
    done_msg    db 10, "=== Arquivo restaurado com sucesso! ===", 10, 0
    done_len    equ $ - done_msg
    err_open    db "Erro: nao foi possivel abrir o arquivo", 10, 0
    err_len     equ $ - err_open
    err_ext     db "Erro: extensao .locked nao encontrada", 10, 0
    err_ext_len equ $ - err_ext

section .bss
    buf         resb 65536        ; buffer de 64KB
    path_out    resb 4096         ; caminho sem extensão .locked

section .text
_start:
    ; --- Pegar argv[1] ---
    pop rdi                 ; argc
    pop rdi                 ; argv[0]
    pop rdi                 ; argv[1] = caminho do arquivo .locked
    cmp rdi, 0
    je .fail

    ; --- Validar e remover extensão .locked ---
    mov rsi, rdi
    call .strlen
    mov rcx, rax            ; comprimento total do caminho
    cmp rcx, ext_len
    jb .fail_ext            ; muito curto para ter .locked

    ; Posicionar no final menos o tamanho da extensão
    mov rsi, rdi
    add rsi, rax
    sub rsi, ext_len

    ; Comparar se termina com ".locked"
    lea rdi, [ext_locked]
    mov rcx, ext_len
.check_ext:
    lodsb
    cmp al, [rdi + rcx - 1]
    jne .fail_ext
    loop .check_ext

    ; Copiar caminho sem os últimos 7 caracteres
    mov rsi, [rsp + 8]      ; argv[1] original
    lea rdi, [path_out]
    sub rcx, rcx
.copy_name:
    cmp rcx, rax
    jge .name_copied
    mov al, [rsi + rcx]
    cmp rcx, rax - ext_len
    jge .zero_byte
    stosb
    inc rcx
    jmp .copy_name
.zero_byte:
    mov byte [rdi], 0
.name_copied:

    ; --- Abrir arquivo em leitura/escrita ---
    mov rax, 2              ; sys_open
    mov rdi, [rsp + 8]      ; caminho original .locked
    mov rsi, 2              ; O_RDWR
    xor rdx, rdx
    syscall
    cmp rax, 0
    jl .fail
    mov r12, rax            ; fd = descritor

    ; --- Ler até 64KB ---
    mov rax, 0              ; sys_read
    mov rdi, r12
    mov rsi, buf
    mov rdx, 65536
    syscall
    mov r13, rax            ; quantidade lida

    ; --- Aplicar XOR NOVAMENTE = DESCRIPTOGRAFAR ---
    xor rbx, rbx            ; índice da chave
    xor rcx, rcx
.decrypt_loop:
    cmp rcx, r13
    jge .decrypt_done
    mov al, [buf + rcx]
    xor al, [key + rbx]
    mov [buf + rcx], al
    inc rcx
    inc rbx
    cmp rbx, key_len
    jl .decrypt_loop
    xor rbx, rbx
    jmp .decrypt_loop
.decrypt_done:

    ; --- Voltar ao início do arquivo ---
    mov rax, 8              ; sys_lseek
    mov rdi, r12
    xor rsi, rsi
    xor rdx, rdx
    syscall

    ; --- Reescrever conteúdo restaurado ---
    mov rax, 1              ; sys_write
    mov rdi, r12
    mov rsi, buf
    mov rdx, r13
    syscall

    ; --- Fechar arquivo ---
    mov rax, 3
    mov rdi, r12
    syscall

    ; --- Renomear removendo .locked ---
    mov rax, 82             ; sys_rename
    mov rdi, [rsp + 8]      ; nome antigo: arquivo.locked
    lea rsi, [path_out]     ; nome novo: arquivo original
    syscall

    ; --- Mensagem de sucesso ---
    mov rax, 1
    mov rdi, 1
    mov rsi, done_msg
    mov rdx, done_len
    syscall

    ; --- Sair ---
    xor rdi, rdi
    mov rax, 60
    syscall

.strlen:
    push rsi
    xor rax, rax
.count:
    cmp byte [rsi + rax], 0
    jz .strlen_end
    inc rax
    jmp .count
.strlen_end:
    pop rsi
    ret

.fail_ext:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_ext
    mov rdx, err_ext_len
    jmp .print_exit

.fail:
    mov rax, 1
    mov rdi, 1
    mov rsi, err_open
    mov rdx, err_len
.print_exit:
    syscall
    mov rdi, 1
    mov rax, 60
    syscall
