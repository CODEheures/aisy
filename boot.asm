[BITS 16]
[ORG 0]

; bios parameters block https://wiki.osdev.org/FAT#BPB_(BIOS_Parameter_Block)
jmp Start
nop
times 33 db 0

Start:
    jmp 0x7C0:Init

Init:
    cli
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    call LoadLoader

; Load 5 sectors on org 0x7E00
LoadLoader:
    mov ah, 2 ; read disk
    mov al, 5 ; 1 sector
    mov ch, 0 ; cylinder 0
    mov cl, 2 ; sector n°2
    mov dh, 0 ; head 0
    mov bx, 0x200 ; offset 200 
    int 0x13
    jc ReadError
    jmp 0x200

ReadError:
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0b1010 ; bios color https://en.wikipedia.org/wiki/BIOS_color_attributes
    mov cx, MessageLen
    mov bp, Message
    xor dx, dx
    int 0x10
    jmp End

End:
    hlt    
    jmp End

Message:    db 'Read disk error'
MessageLen: equ $-Message

times 510 - ($-$$) db 0

; Boot signature
db 0x55
db 0xAA