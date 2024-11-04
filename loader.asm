[BITS 16]
[ORG 0x7E00]

Start:
    call TestCpuidFeatureSupport
    call TestLongModeSupport
    call TestLong1GPageModeSupport
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

EndSuccess:
    mov cx, SuccessMessageLen
    mov bp, SuccessMessage
    call Message
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

Message1:    db 'Cpuid Feature is not supported'
MessageLen1: equ $-Message1

Message2:    db 'Long Mode is not supported'
MessageLen2: equ $-Message2

Message3:    db '1G page Mode not supported'
MessageLen3: equ $-Message3

SuccessMessage:    db 'Load success'
SuccessMessageLen: equ $-SuccessMessage

times 512*5-($ - $$) db 0