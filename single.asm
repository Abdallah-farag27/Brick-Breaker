public single

extrn sBricks:FAR 
extrn sDRAW_BALL:far
extrn sMOVE_BALL:far
extrn sClear_BALL:far
extrn smoveBar:far
extrn sdrawBar:far
extrn sdir:byte
.model small

.stack 100h
.data

PREV_TIMESTEP db 0

.code

single proc far
    ; mov ax, @data
    ; mov ds, ax
    mov ax,12h
    int 10h
    call sBricks
CHECK_TIME:

		mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	
		MOV PREV_TIMESTEP, DL ; update the previous time step

		; Clear the screen
		call sClear_BALL
		call sMOVE_BALL
		call sDRAW_BALL
        
        
        call sdrawBar
        mov ah,1
        int 16h
        jz next
        mov ah,0
        int 16h
        cmp ah, 4Bh
        jz smovebarleft
        cmp ah, 4Dh
        jz smovebarright

        next:
        ;rest of code
            jmp CHECK_TIME
        smovebarright:
            mov sdir, 1
            call smoveBar
            jmp CHECK_TIME
        smovebarleft:
            mov sdir, 0
            call smoveBar
            jmp CHECK_TIME
    ; mov ah, 4Ch
    ; int 21h
    ; call barDraw
    ret

single endp
end