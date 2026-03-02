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
		sub cx, 3

		mov si, 84h			;basic command len beginning

		mov al, 4eh
		mov bp, 4eh			;basic colour

		cmp byte ptr ds:[82h], '0'
		je basic_way

		mov di, 84h
		call read_colour	;phrase colour in al

		mov bp, ax			;phrase colour in bp
		call read_colour	;frame colour in al

basic_way:
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
		mov es:byte ptr[bx+1], al
		add bx, 2					;left upper corner

		call print_horisontal_frame

		mov es:byte ptr[bx], 0bbh
		mov es:byte ptr[bx+1], al	;right upper corner

		mov cx, dx
		sub bx, cx
		sub bx, cx
		add bx, 320

		sub bx, 2
		mov es:byte ptr[bx], 0c8h
		mov es:byte ptr[bx+1], al
		add bx, 2					;left lower corner

		call print_horisontal_frame

		mov es:byte ptr[bx], 0bch
		mov es:byte ptr[bx+1], al	;right lower corner

end_of_programm:
		mov ax, 4c00h		;end of programm
		int 21h
;-------------------------------------------------------------------------------
;Prints command line with start in es:[bx] and left and right frame of phrase
;Entry:	es:[bx] --> place to write command line
;	    cx       = command line len
;		di 		--> start of command line
;		bp		 = phrase colour
;		al       = frame colour
;Exit:            = NO EXIT
;Destr:  di,
;-------------------------------------------------------------------------------
print_str:
		sub bx, 2
		mov es:byte ptr[bx], 0bah
		mov es:byte ptr[bx+1], al
		add bx, 2 			;print left frame

		push ax

print_letter:
		mov al, [di]
		mov es:byte ptr[bx], al
		mov es:word ptr[bx+1], bp
		add bx, 2
		inc di
		loop print_letter		;print phrase

		pop ax

		mov es:byte ptr[bx], 0bah
		mov es:byte ptr[bx+1], al	;print right frame

		ret
		endp
;------------------------------------------------------------------------------
;Prints horisontal phrame starts in bx
;Entry: es:[bx] --> place to start horisontal phrame
;	cx       =  line len
;	al		 = frame colour
;Exit:		    NO EXIT
;Destr: bx, cx
;--------------------------------------------------------------------------------
print_horisontal_frame:
		mov es:byte ptr[bx], 0cdh
		mov es:byte ptr[bx+1], al
		add bx, 2
		loop print_horisontal_frame
		ret
		endp
;------------------------------------------------------------------
;Interpritate 16 code as color and put in bp
;Entry: di --> address of colour str
;Exit:	ax --> colour code
;Destr:
;--------------------------------------------------------------------
read_colour:
		mov ax, 0		;zero colour code

		mov dx, 10

new_number:
		mul dx

		cmp ds:byte ptr[di], '0'
		jb end_of_programm
		cmp ds:byte ptr[di], '9'
		ja end_of_programm

		add al, ds:byte ptr[di]
		sub al, '0'

		inc di
		dec cx
		mov dx, 10

		cmp ds:byte ptr[di], ' '
		jne new_number

		dec cx
		inc di 			;ignore ' '

		ret
		endp
;--------------------------------------------------------------





end		start
