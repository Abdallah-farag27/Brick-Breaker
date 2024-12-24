public game

extrn Bricks:FAR 
extrn DRAW_BALL:far
extrn MOVE_BALL:far
extrn Clear_BALL:far
extrn moveBar:far
extrn drawBar:far
extrn dir:byte
.model small

.stack 100h
.data

PREV_TIMESTEP db 0

.code

game proc far
    ; mov ax, @data
    ; mov ds, ax
    mov ax,12h
    int 10h
    call Bricks
CHECK_TIME:

		mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	
		MOV PREV_TIMESTEP, DL ; update the previous time step

		; Clear the screen
		call Clear_BALL
		call MOVE_BALL
		call DRAW_BALL
        
        
        call drawBar
        mov ah,1
        int 16h
        jz next
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
            call moveBar
            jmp CHECK_TIME
        movebarleft:
            mov dir, 0
            call moveBar
            jmp CHECK_TIME
    ; mov ah, 4Ch
    ; int 21h
    ; call barDraw
    ret

game endp
end