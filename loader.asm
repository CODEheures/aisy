[BITS 16]
[ORG 0x7E00]

Start:
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0b1010 ; bios color https://en.wikipedia.org/wiki/BIOS_color_attributes
    mov cx, MessageLen
    mov bp, Message
    xor dx, dx
    int 0x10

End:
    hlt
    jmp End

Message:    db 'Loader file loaded success'
MessageLen: equ $-Message

times 512*5-($ - $$) db 0