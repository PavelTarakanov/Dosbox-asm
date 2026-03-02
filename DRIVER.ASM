.model tiny
.code
org 100h

Start:
	mov ax, 3509h   ;new one
	int 21h
	mov Old09Ofs, bx
	mov bx, es
	mov Old09Seg, bx

	push 0
	pop es

	cli
	mov bx, 09h * 4
	mov es:[bx], offset My09Int

	mov ax, cs
	mov es:[bx+2], ax
	sti

	mov ax, 3100h

	mov dx, offset EndOfProgram ;16 bytes
	shr dx, 4   ;1  byte
	inc dx

	int 21h    ;until now: drivers init code


My09Int proc
	push ax bx es

	push 0b800h
	pop es

	mov bx, (5 * 80d + 40d) * 2
	mov ah, 4eh

	in al, 60h
	mov es:[bx], ax

	or al, 80h
	out 61h, al
	and al, not 80h
	out 61h, al   ;replace header bite (0 to 1, 1 to 0)

	mov al, 20h
	out 20h, al

	pop es bx ax

	db 0eah    ;JMP FAR
	Old09Ofs dw 0   ;new one
	Old09Seg dw 0

	dd 90909090h

	endp

EndOfProgram:

end Start
