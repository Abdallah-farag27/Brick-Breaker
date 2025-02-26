moveCursor macro row,col
               mov ah,02h
               mov dh,row
               mov dl,col
               mov bh,0
               int 10h
endm

public single

extrn sBricks:FAR 
extrn sDRAW_BALL:far
extrn sMOVE_BALL:far
extrn sClear_BALL:far
extrn smoveBar:far
extrn sdrawBar:far
extrn quit:far
extrn sdir:byte
extrn sLives:byte
extrn sScore1:byte
extrn sScore2:byte
extrn sTotScore:byte
extrn WorL:byte
.model small

.stack 100h
.data

PREV_TIMESTEP db 0
message db 'Lives Remaining: $'
Scoremess db 'Score: $'
.code
DisplayLives proc
    ; cmp Lives, 0
    ; jnz quit222
    moveCursor 28,5
    mov ah, 09h
    lea dx, message
    int 21h
    mov dl, sLives 
    add dl, 30h
    mov ah, 02h
    int 21h
quit222: 
    ret
DisplayLives endp
;;;

DisplayScore proc
    moveCursor 28,65
    mov ah, 09h
    lea dx, Scoremess
    int 21h
    mov dl, sScore2   
    add dl, 30h
    mov ah, 02h
    int 21h
    mov dl, sScore1   
    add dl, 30h
    mov ah, 02h
    int 21h
    ret
DisplayScore endp

single proc far
    ; mov ax, @data
    ; mov ds, ax
    mov ax,12h
    int 10h
    call sBricks
CHECK_TIME:

        cmp sLives, 0  
        jnz sComp
        mov WorL, '0'
        call quit

 sComp: cmp sTotScore, 20
        jnz continue
        mov WorL, '1'
        call quit

continue:		
        mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	
		MOV PREV_TIMESTEP, DL ; update the previous time step

		; Clear the screen
        call DisplayLives
        call DisplayScore
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
        cmp al, 27
        jnz next
        mov ah, 4Ch
        int 21h

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