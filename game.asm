public game

extrn Bricks:FAR 
extrn DRAW_BALL:far
extrn MOVE_BALL:far
extrn Clear_BALL:far
extrn moveBar:far
extrn drawBar:far
extrn dir:byte
extrn rdir:byte
; extrn WINDOW_WIDTH:word
; extrn START_X:word
; extrn currWidth:word
; extrn startColumn:word
; extrn endColumn:word
extrn Brlr:byte
extrn Bllr:byte
extrn Barlr:byte

initPort MACRO
    ;Set Divisor Latch Access Bit
    MOV DX, 3FBh 				; Line Control Register
    MOV AL, 10000000b			;Set Divisor Latch Access Bit
    OUT DX, AL					;Out it
	
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    MOV DX, 3F8h			
    MOV AL, 0Ch			
    OUT DX, AL

    ;Set MSB byte of the Baud Rate Divisor Latch register.
    MOV DX, 3F9h
    MOV AL, 00h
    OUT DX, AL

    ;Set port configuration
    MOV DX, 3FBh
    MOV AL, 00011011b
    OUT DX, AL
ENDM

.model small

.stack 100h
.data

PREV_TIMESTEP db 0

.code

splitScreen proc
    mov cx, 320
    mov dx, 0
drawPixel:
    mov AH, 0Ch
	mov al, 0Fh
    mov bh, 0
    int 10h
    inc dx
    cmp dx, 480
	jl drawPixel
ret
splitScreen endp

game proc far
    initPort
    mov ax,12h
    int 10h
    mov Brlr,'1'
    call Bricks
    mov Brlr,'0'
    call Bricks
             
CHECK_TIME:

		mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	
		MOV PREV_TIMESTEP, DL ; update the previous time step

		; Clear the screen
        call splitScreen
        mov Bllr,'1'
		call Clear_BALL
		call MOVE_BALL
		call DRAW_BALL

        mov Bllr,'0'
		call Clear_BALL
		call MOVE_BALL
		call DRAW_BALL
        
        mov Barlr,'0'
        call drawBar
        mov Barlr,'1'
        call drawBar
left:
        mov ah,1
        int 16h
        jz right
        mov ah,0
        int 16h
        cmp ah, 4Bh
        jz movebarleft
        cmp ah, 4Dh
        jz movebarright

        next:
        ;rest of code
            jmp CHECK_TIME
        movebarright:
            mov dir, 1
            mov Barlr,'1'
            mov dx,3FDH 			;Line Status Register
            in al , dx 				;Read Line Status
            AND al , 00100000b
            jz right 
            mov dx, 3F8H			;Transmit data register
            mov al, 'r'       	;put the data into al
            out dx, al
            call moveBar
            jmp CHECK_TIME
        movebarleft:
            mov dir, 0
            mov Barlr,'1'
            mov dx,3FDH 			;Line Status Register
            in al , dx 				;Read Line Status
            AND al , 00100000b
            jz right 
            mov dx, 3F8H			;Transmit data register
            mov al, 'l'       	;put the data into al
            out dx, al
            call moveBar
            jmp CHECK_TIME
right:
    MOV DX, 3FDh		;line status register
	in AL, DX			;take from the line register into AL
	AND al, 1			;check if its not empty
	JZ next	
    MOV DX, 03F8h
	in al, dx
    cmp al, 'l'
    jz rmovebarleft
    rmovebarright:
            mov rdir, 1
            mov Barlr,'0'
            call moveBar
            jmp next
    rmovebarleft:
            mov rdir, 0
            mov Barlr,'0'
            call moveBar
            jmp next	
    jmp next
    ret

game endp
end