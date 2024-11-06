[BITS 16]
[ORG 0x7E00]

Start:
    call TestCpuidFeatureSupport
    call TestLongModeSupport
    call TestLong1GPageModeSupport
    call TestA20Enabled
    call SetVideoMode
    call EndSuccess

TestCpuidFeatureSupport:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb NotSupported1
    ret

TestLongModeSupport:
    mov eax, 0x80000001
    cpuid
    test edx, (1<<29)
    jz NotSupported2 
    ret

TestLong1GPageModeSupport:
    mov eax, 0x80000001
    cpuid
    test edx, (1<<26)
    jz NotSupported3 
    ret

TestA20Enabled:
    xor ax, ax
    mov ds, ax
    mov ax, 0xFFFF
    mov es, ax
    mov word[ds:0x7C00], 0xA200 ; A200 in 7C00 memory
    cmp word[es:0x7C10], 0xA200 ; Compare 0xFFFF:Ox7c10 (0xFFFF0 + 7C00=107C00 = 000100000111110000000000 => bit 20 = 1)
    jne .A20Enabled ; Not equal implied Address ES is not reduced to Address 7c00
    mov word[ds:0x7C00], 0xB200 ; Test 2 is case of equality in test 1 because test 1 may be a statistical chance
    cmp word[es:0x7C10], 0xB200 
    jz NotSupported4 
.A20Enabled:
    xor ax, ax
    mov es, ax
    ret

SetVideoMode:
    mov ah, 0 ; setting video mode function
    mov al, 3 ; setting video mode as text mode (0xb8000 memory start characters (80*25 chars))
    int 0x10

EndSuccess:
    mov cx, SuccessMessageLen
    mov si, SuccessMessage
    call VideoModeMessage
    jmp End

End:
    hlt
    jmp End

NotSupported1:
    mov cx, MessageLen1
    mov bp, Message1
    jmp ErrorMessage

NotSupported2:
    mov cx, MessageLen2
    mov bp, Message2
    jmp ErrorMessage

NotSupported3:
    mov cx, MessageLen3
    mov bp, Message3
    jmp ErrorMessage

NotSupported4:
    mov cx, MessageLen4
    mov bp, Message4
    jmp ErrorMessage

Message:
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0b1010 ; bios color https://en.wikipedia.org/wiki/BIOS_color_attributes
    xor dx, dx
    int 0x10
    ret

ErrorMessage:
    call Message
    jmp End

VideoModeMessage:
    mov ax, 0xb800 ; to prepare Oxb8000 addr (es:di 0xb800:0x0 = 0xb8000)
    mov es, ax
    xor di, di
    call PrintTextVideoMode
    ret

PrintTextVideoMode:
    mov al, [si] ; current char in al
    mov [es:di], al ; al in 0xb800:0x0000 (=Oxb8000)
    add di, 1 ; to set next byte in memory
    mov byte[es:di], 0xa ; foreground green/background black after char
    add di, 1 ; to set next byte
    add si, 1 ; to read next char
    loop PrintTextVideoMode ; loop decrement cx and loop if cx > 0

Message1:    db 'Cpuid Feature is not supported'
MessageLen1: equ $-Message1

Message2:    db 'Long Mode is not supported'
MessageLen2: equ $-Message2

Message3:    db '1G page Mode not supported'
MessageLen3: equ $-Message3

Message4:    db 'A20 not enabled'
MessageLen4: equ $-Message4

SuccessMessage:    db 'Load success'
SuccessMessageLen: equ $-SuccessMessage

times 512*5-($ - $$) db 0