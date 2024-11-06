[BITS 16]
[ORG 0x7C00]

Start:
    xor ax,ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    call PrintMessage
    jmp End

End:
    hlt    
    jmp End

PrintMessage:
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0b1010 ; bios color https://en.wikipedia.org/wiki/BIOS_color_attributes
    mov cx, MessageLen
    mov bp, Message
    xor dx, dx
    int 0x10

Message: db 'Hello world!'
MessageLen: equ $-Message

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