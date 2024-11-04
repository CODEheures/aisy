[BITS 16]
[ORG 0x7C00]

Start:
    xor ax,ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    call TestDiskExtension
    call LoadLoader

TestDiskExtension:
    mov [DriveId], dl
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13
    jc NotSupported
    cmp bx, 0xAA55
    jne NotSupported
    ret

; Load 5 sectors on org 0x7E00
LoadLoader:
    mov si, Packet ; packet describe here: https://www.ctyme.com/intr/rb-0708.htm#Table272
    mov byte[si], 0x10 ; size of packet (16bytes)
    mov byte[si+1], 0 ; reserved 0
    mov word[si+2], 5 ; number of sector to load
    mov word[si+4], 0x7E00 ; Offset
    mov word[si+6], 0 ; Segment => 0 * 16 + 0x7e00 = 0x7e00
    mov dword[si+8], 1 ; Starting sector LBA
    mov dword[si+0xC], 0 ; Starting sector HBA
    mov dl, [DriveId]
    mov ah, 0x42
    int 0x13
    jc ReadError
    mov [DriveId], dl
    jmp 0x7E00

NotSupported:
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

Packet:     times 16 db 0
DriveId:    db 0
Message:    db 'Boot error'
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