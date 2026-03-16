.model tiny
.code
org 100h


start:
        mov ah, 0ah
        mov dx, offset password
        int 21h                     ;str input

        xor bx, bx                  ;bx = 0
        mov bl, password[1]         ;real str len
        mov password[bx+2], '$'     ;'$' at the end of str

        call hash_calculate

        mov ax, hash
        mov bx, correct_hash

        cmp ax, bx
        jne incorrect

        mov ah, 09h
        mov dx, offset correct_phrase
        int 21h

        jmp prog_end

incorrect:
        mov ah, 09h
        mov dx, offset incorrect_phrase
        int 21h

prog_end:
		mov ax, 4c00h
		int 21h

password            db 20                  ; max len
                    db 0                   ; real len
                    db 10 dup ('$')
hash                dw 0
correct_hash        dw 8770h
;---------------------------------------------------------------
;Calculates password hash
;Entry: password[1] = password len
;       password[2] = password begin
;Exit:  hash        = password hash
;Destr: ax, bx
;---------------------------------------------------------------
hash_calculate proc

        xor ax, ax              ;ax = 0
        xor bx, bx

one_letter:                     ;calculate hash in al
        add al, password[bx+2]
        shl ax, 1
        add ax, ax
        inc bx
        mov ch, password[bx+2]
        cmp ch, '$'
        jne one_letter

        mov hash, ax            ;hash in hash

        ret
        endp
correct_phrase      db 'Correct password$'
incorrect_phrase    db 'Incorrect password$'
end 		Start

