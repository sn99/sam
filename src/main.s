%define video_interrupt 0x10
; Display a character on the screen, advancing the cursor and scrolling the screen as necessary 
%define function_teletype 0x0e
; A20-Gate activate
%define a20_gate_active 0x15

[bits 16]    ; use 16 bits
[org 0x7c00] ; sets the start address

section .data
    msg: db "Hello world!", 0

init: 
    mov ax, 0x2401
    int a20_gate_active
    mov ax, 0x3
    int video_interrupt ; set vga text mode 3
    cli
    lgdt [gdt_pointer] ; load the gdt table
    mov eax, cr0
    or eax, 0x1 ; set the protected mode bit on special CPU reg cr0
    mov cr0, eax
    jmp CODE_SEG:boot ; long jump to the code segment

gdt_start:
    dq 0x0

gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0

gdt_end:

gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 32]
boot:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esi, msg
	mov ebx, 0xb8000

print_char: 
    lodsb
    or al, al
    jz halt
	or eax, 0x0200 ; change color 1st for background 2nd for foreground
	mov word [ebx], ax
	add ebx, 2
	jmp print_char

halt:
    cli
    hlt ; CPU stop/halt execution

; Pad to 510 bytes (boot sector size minus 2) with 0s, and finish with the two-byte standard boot signature
times 510-($-$$) db 0
dw 0xAA55  ; => 0x55 0xAA (little endian byte order)
