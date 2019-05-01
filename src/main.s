%define video_interrupt 0x10
; Display a character on the screen, advancing the cursor and scrolling the screen as necessary 
%define function_teletype 0x0e

[bits 16]    ; use 16 bits
[org 0x7c00] ; sets the start address

section .data
    msg: db "Hello world!", 0

init: 
    mov si, msg  
    mov ah, function_teletype

print_char: 
    lodsb     
    cmp al, 0
    je done
    int video_interrupt  
    jmp print_char

done:
    cli
    hlt ; CPU stop/halt execution

; Pad to 510 bytes (boot sector size minus 2) with 0s, and finish with the two-byte standard boot signature
times 510-($-$$) db 0
dw 0xAA55  ; => 0x55 0xAA (little endian byte order)
