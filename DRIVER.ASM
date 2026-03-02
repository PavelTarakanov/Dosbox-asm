.model tiny
.code
org 100h

VIDEOSEG equ 0b800h

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
;-------------------------------------------------------------------------
;
;
;--------------------------------------------------------------------------
My09Int proc
	push ax bx es

	push VIDEOSEG
	pop es

	mov bx, (5 * 80d + 40d) * 2
	mov ah, 4eh

	in al, 60h
	mov es:[bx], ax

	cmp al, 36h
	jne no_reg_open
	call reg_frame

no_reg_open:

	cmp al, 1ch
	jne no_reg_close
	call delete_reg_frame

no_reg_close:

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
;-------------------------------------------------------------------------
;Prints regs frame in the left corner
;
;
;
;-------------------------------------------------------------------------
reg_frame proc

		mov al, 10

		mov bx, 2*(2*80-12)
		mov cx, 5

		call print_horisontal_frame			;upper horisontal frame

		mov bx, 2*(10*80-12)
		mov cx, 5

		call print_horisontal_frame			;lower horisontal frame

		mov bx, 2*(3*80-13)
		mov cx, 7

		call print_vertical_frame			;left vertical frame

		mov bx, 2*(3*80-7)
		mov cx, 7

		call print_vertical_frame			;right vertical frame

		mov es:byte ptr[2*(2*80-7)], 0bbh
		mov es:byte ptr[2*(2*80-7)+1], al 	;right upper corner

		mov es:byte ptr[2*(2*80-13)], 0c9h
		mov es:byte ptr[2*(2*80-13)+1], al 	;left upper corner

		mov es:byte ptr[2*(10*80-7)], 0bch
		mov es:byte ptr[2*(10*80-7)+1], al 	;right lower corner

		mov es:byte ptr[2*(10*80-13)], 0c8h
		mov es:byte ptr[2*(10*80-13)+1], al 	;left lower corner
		ret
		endp
;-------------------------------------------------------------------------
;Deletes regs frame
;
;
;
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
;Prints vertical phrame starts in bx
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
EndOfProgram:

end Start
