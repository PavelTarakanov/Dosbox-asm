.model tiny
.code
org 100h

VIDEOSEG equ 0b800h

Start:			;//TODO после метки End и прыгать туда
	mov ax, 3509h   			;new one
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
	shr dx, 4   				;1  byte
	inc dx

	int 21h    					;until now: drivers init code
;-------------------------------------------------------------------------
;
;
;--------------------------------------------------------------------------
My09Int proc
	push ax bx es

	push VIDEOSEG
	pop es						;videoseg address in es

	in al, 60h

	push ax

	cmp al, 36h
	jne no_reg_open
	call reg_frame				;//TODO 8 прерывание

no_reg_open:

	cmp al, 1ch
	jne no_reg_close
	;call delete_reg_frame

no_reg_close:

	pop ax

	or al, 80h
	out 61h, al
	and al, not 80h
	out 61h, al   				;replace header bite (0 to 1, 1 to 0)

	mov al, 20h
	out 20h, al

	pop es bx ax

	db 0eah    ;JMP FAR
	Old09Ofs dw 0   ;new one
	Old09Seg dw 0

	dd 90909090h

	endp
;-------------------------------------------------------------------------
;Prints regs frame in the left corner
;Entry: NO ENTRY
;Exit:  NO EXIT
;Destr: nothing
;-------------------------------------------------------------------------
reg_frame proc
		push cs ss es ds sp bp di si dx cx bx ax

		mov bx, 2*(2*80 - 16)
		mov ah, 0cdh
		mov al, 1ah
		mov dh, 0c9h
		mov dl, 1ah
		mov si, 0bb1ah
		mov cx, 11				;upper horisontal frame

		call print_line

		xor ah, ah
		mov dh, 0bah
		mov si, 0ba1ah			;prepare for central part

		mov di, 12				;frame high in di

central_part:

		mov cx, 11				;frame len
		add bx, 2*80 - 12*2		;to new line
		call print_line
		dec di

		cmp di, 0
		ja central_part			;central part print

		add bx, 2*80 - 12*2		;new line
		mov ah, 0cdh
		mov dh, 0c8h
		mov si, 0bc1ah
		mov cx, 11				;prepare for lower horisontal frame

		call print_line			;lower horisontal frame

		call print_reg_names

		mov cx, 12					;number of lines
		mov bx, 2*(3*80-11)			;equals place

print_equals:

		mov es:byte ptr[bx], '='	;print '='
		add bx, 2*80				;new line

		loop print_equals

		mov cx, 12					;number of regs
		mov bx, 2*(3*80-9)			;place for reg

regs_values:
		pop ax						;reg value in ax
		call print_reg_value
		add bx, 160					;new str
		loop regs_values

		ret
		endp
;-------------------------------------------------------------------------
;Deletes regs frame
;Entry: NO ENTRY
;Exit:  NO EXIT
;Destr:
;-------------------------------------------------------------------------
delete_reg_frame proc

		ret
		endp
;------------------------------------------------------------------------------
;Prints horisontal phrame starts in bx
;Entry: es:[bx] --> place to start horisontal phrame
;		cx       =  line len
;		al		 = frame colour
;Exit:		    NO EXIT
;Destr: bx, cx
;--------------------------------------------------------------------------------
print_horisontal_frame proc
		mov es:byte ptr[bx], 0cdh
		mov es:byte ptr[bx+1], al
		add bx, 2
		loop print_horisontal_frame
		ret
		endp
;---------------------------------------------------------------------
;------------------------------------------------------------------------------
;Prints vertical frame starts in bx
;Entry: es:[bx] --> place to start horisontal phrame
;		cx       =  line len
;		al		 = frame colour
;Exit:		    NO EXIT
;Destr: bx, cx
;--------------------------------------------------------------------------------
print_vertical_frame proc
		mov es:byte ptr[bx], 0bah
		mov es:byte ptr[bx+1], al
		add bx, 160
		loop print_vertical_frame
		ret
		endp
;---------------------------------------------------------------------
;---------------------------------------------------------------------
;Prints horisontal line with special left and right symbol, begin in bx
;Entry: es:[bx] --> place to start line
;		ah		 =  symbol for central part
;		al		 =  colour for central part
;		dh		 =  symbol for left part
;		dl		 =  colour for left part
;		cx		 =  central part len
; 		si 		 =  right symbol and colour
;Exit:
;Destr:
;---------------------------------------------------------------------
print_line proc
		mov es:byte ptr[bx], dh
		mov es:byte ptr[bx+1], dl	;prints left symbol

		add bx, 2

print_central_part:

		mov es:byte ptr[bx], ah
		mov es:byte ptr[bx+1], al
		add bx, 2
		loop print_central_part		;prints central part of line

		mov dx, si					;right symbol and colour in dx

		mov es:byte ptr[bx], dh
		mov es:byte ptr[bx+1], dl	;prints right symbol

		ret
		endp
;---------------------------------------------------------------------
;Print reg names
;Entry: NO ENTRY
;Exit:  NO EXIT
;Destr: bx
;---------------------------------------------------------------------
print_reg_names proc

		mov bx, 2*(80*3-14)
		mov es:byte ptr[bx], 'a'
		add bx, 2
		mov es:byte ptr[bx], 'x'	;print ax name

		mov bx, 2*(80*4-14)
		mov es:byte ptr[bx], 'b'
		add bx, 2
		mov es:byte ptr[bx], 'x'	;print bx name

		mov bx, 2*(80*5-14)
		mov es:byte ptr[bx], 'c'
		add bx, 2
		mov es:byte ptr[bx], 'x'	;print cx name

		mov bx, 2*(80*6-14)
		mov es:byte ptr[bx], 'd'
		add bx, 2
		mov es:byte ptr[bx], 'x'	;print dx name

		mov bx, 2*(80*7-14)
		mov es:byte ptr[bx], 's'
		add bx, 2
		mov es:byte ptr[bx], 'i'	;print si name

		mov bx, 2*(80*8-14)
		mov es:byte ptr[bx], 'd'
		add bx, 2
		mov es:byte ptr[bx], 'i'	;print di name

		mov bx, 2*(80*9-14)
		mov es:byte ptr[bx], 'b'
		add bx, 2
		mov es:byte ptr[bx], 'p'	;print bp name

		mov bx, 2*(80*10-14)
		mov es:byte ptr[bx], 's'
		add bx, 2
		mov es:byte ptr[bx], 'p'	;print sp name

		mov bx, 2*(80*11-14)
		mov es:byte ptr[bx], 'd'
		add bx, 2
		mov es:byte ptr[bx], 's'	;print ds name

		mov bx, 2*(80*12-14)
		mov es:byte ptr[bx], 'e'
		add bx, 2
		mov es:byte ptr[bx], 's'	;print es name

		mov bx, 2*(80*13-14)
		mov es:byte ptr[bx], 's'
		add bx, 2
		mov es:byte ptr[bx], 's'	;print ss name

		mov bx, 2*(80*14-14)
		mov es:byte ptr[bx], 'c'
		add bx, 2
		mov es:byte ptr[bx], 's'	;print cs name

		ret
		endp
;---------------------------------------------------------------------
;Prints reg values
;Entry: es:[bx] --> place to print reg value
;		ax		 =  reg value
;Exit:  NO EXIT
;Destr: dx, si
;---------------------------------------------------------------------
print_reg_value proc
		push cx

		mov cx, 4
		add bx, 6

one_digit:
		xor dx, dx

		push bx
		mov bx, 16

		div bx

		lea si, hexadecimal_digits
		add si, dx
		mov dl, cs:[si]

		pop bx
		mov es:byte ptr[bx], dl
		sub bx, 2

		loop one_digit

		add bx, 2
		pop cx

		ret
		endp
;---------------------------------------------------------------------
EndOfProgram:
hexadecimal_digits db '0123456789abcdef'

end Start
