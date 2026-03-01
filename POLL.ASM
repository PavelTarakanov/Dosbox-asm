.286
.model tiny
.code
org 100h

Start: 		push 0b800h
		pop es			;video memory seg

		mov bx, (5*80+40)*2	;fifth row, center
		mov ah, 4eh		;colour

Next:		in al, 60h		;port read
		mov es:[bx], ax

		cmp al, 1
		jne Next

		mov ax, 4c00h
		int 21h
end 		Start