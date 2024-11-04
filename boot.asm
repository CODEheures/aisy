ORG 0x7C00
BITS 16

start:
    mov si, message
    call print
.end:
    hlt    
    jmp .end

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret

message: db 'Hello world!', 0

; 0 to 1be partitions entries
times 0x1be-($ - $$) db 0

; Info partition 1
db 0x80 ; bootable partition
db 0 ; starting head
db 1 ; starting sector (bit 6 and 7 used for starting cylinder)
db 0 ; starting cylinder
db 0x0F ; extended partition type
db 0xFF ; end head
db 0xFF ; end sector (bit 6 and 7 used for endind cylinder)
db 0xFF ; end cylinder
dd 1 ; start Sector (4 bytes)
dd (20*16*63-1) ; Number of sectors (20 cyinders, 16 head, 63 sectors moins 1 start)

; 0 for Infos partitions 2/3/4
times (16*3) db 0

; Boot signature
db 0x55
db 0xAA