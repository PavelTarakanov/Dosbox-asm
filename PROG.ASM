.model tiny
.code
org 100h

VIDEOSEG 	equ 0b800h

start:
		mov ax, VIDEOSEG
		mov es, ax

		mov bx, 80*2*13		;central row

		mov cx, ds:[80h]

		xor ch, ch
		dec cx			;cx = phrase len

		mov dx, 80 		;center of line
		test cx, 1
		jz even_len
		inc dx

even_len:
		sub dx, cx		;begin of phrase in dx

		add bx, dx
		mov dx, cx		;saved cx(command line len) in dx

		call print_str

		mov cx, dx
		sub bx, cx
		sub bx, cx
		sub bx, 160

		sub bx, 2
		mov es:byte ptr[bx], 0c9h
		mov es:byte ptr[bx+1], 4ch
		add bx, 2					;left upper corner

		call print_horisontal_frame

		mov es:byte ptr[bx], 0bbh
		mov es:byte ptr[bx+1], 4ch	;right upper corner

		mov cx, dx
		sub bx, cx
		sub bx, cx
		add bx, 320

		sub bx, 2
		mov es:byte ptr[bx], 0c8h
		mov es:byte ptr[bx+1], 4ch
		add bx, 2					;left lower corner

		call print_horisontal_frame

		mov es:byte ptr[bx], 0bch
		mov es:byte ptr[bx+1], 4ch	;right lower corner

		mov ax, 4c00h		;end of programm
		int 21h
;-------------------------------------------------------------------------------
;Prints command line with start in es:[bx] and left and right frame of phrase
;Entry:	es:[bx] --> place to write command line
;	cx       = command line len
;Exit:            = NO EXIT
;Destr:  si
;-------------------------------------------------------------------------------
print_str:
		mov si, 82h			;begin of command line

		sub bx, 2
		mov es:byte ptr[bx], 0bah
		mov es:byte ptr[bx+1], 4ch
		add bx, 2 			;print left frame

print_letter:
		mov al, [si]
		mov es:byte ptr[bx], al
		mov es:byte ptr[bx+1], 4ch
		add bx, 2
		inc si
		loop print_letter		;print phrase


		mov es:byte ptr[bx], 0bah
		mov es:byte ptr[bx+1], 4ch	;print right frame

		ret
		endp
;------------------------------------------------------------------------------
;Prints horisontal phrame starts in bx
;Entry: es:[bx] --> place to start horisontal phrame
;	cx       =  line len
;Exit; 		    NO EXIT
;Destr: bx, cx	
;--------------------------------------------------------------------------------
print_horisontal_frame:
		mov es:byte ptr[bx], 0cdh
		mov es:byte ptr[bx+1], 4ch
		add bx, 2
		loop print_horisontal_frame
		ret
		endp

end		start
