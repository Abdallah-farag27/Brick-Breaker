moveCursor macro row,col
               mov ah,02h
               mov dh,row
               mov dl,col
               mov bh,0
               int 10h
endm
public game

extrn Bricks:FAR 
extrn DRAW_BALL:far
extrn MOVE_BALL:far
extrn Clear_BALL:far
extrn moveBar:far
extrn drawBar:far
extrn ResetBrick:FAR
extrn dir:byte
extrn rdir:byte
extrn Brlr:byte
extrn Bllr:byte
extrn Barlr:byte
extrn Lives:byte
extrn rLives:byte
extrn quit:far
extrn WorL:byte
extrn Score1:byte
extrn rScore1:byte
extrn Score2:byte
extrn rScore2:byte
extrn TotScore:byte
extrn rTotScore:byte

.model small

.stack 100h
.data

PREV_TIMESTEP db 0
message db 'Lives Remaining: $'
Scoremess db 'Score: $'
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

DisplayLives proc
    ; cmp Lives, 0
    ; jnz quit222
    moveCursor 28,1
    mov ah, 09h
    lea dx, message
    int 21h
    mov dl, Lives   
    add dl, 30h
    mov ah, 02h
    int 21h
    moveCursor 28,42
    mov ah, 09h
    lea dx, message
    int 21h
    mov dl, rLives   
    add dl, 30h
    mov ah, 02h
    int 21h
quit222: 
    ret
DisplayLives endp


DisplayScore proc
    moveCursor 28,28
    mov ah, 09h
    lea dx, Scoremess
    int 21h
    mov dl, Score2   
    add dl, 30h
    mov ah, 02h
    int 21h
    mov dl, Score1   
    add dl, 30h
    mov ah, 02h
    int 21h
    moveCursor 28,70
    mov ah, 09h
    lea dx, Scoremess
    int 21h
    mov dl, rScore2   
    add dl, 30h
    mov ah, 02h
    int 21h
    mov dl, rScore1   
    add dl, 30h
    mov ah, 02h
    int 21h
    ret
DisplayScore endp

game proc far
    mov ax,12h
    int 10h
    ; call ResetBrick
    mov Brlr,'1'
    call Bricks
    mov Brlr,'0'
    call Bricks
             
CHECK_TIME:

        cmp Lives, 0
        jnz CHECK_WIN
        mov WorL, '0'
        call quit

CHECK_WIN:      
        cmp rLives, 0
        jnz scmp
        mov WorL, '1'
        call quit

scmp:   cmp TotScore, 20
        jnz CHECK_LOSE
        mov WorL, '1'
        call quit

CHECK_LOSE:      
        cmp rTotScore, 20
        jnz Continue
        mov WorL, '0'
        call quit


Continue:
		mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	
		MOV PREV_TIMESTEP, DL ; update the previous time step

		; Clear the screen
        call DisplayLives
        call DisplayScore
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
        cmp al, 27
        jnz next
        mov dx,3FDH 			
            in al , dx 				
            AND al , 00100000b
            jz right 
            mov dx, 3F8H		
            mov al, 'e'   
            out dx, al
        mov ah, 4Ch
        int 21h

        next:
            jmp CHECK_TIME
        movebarright:
            mov dir, 1
            mov Barlr,'1'
            mov dx,3FDH 			
            in al , dx 				
            AND al , 00100000b
            jz right 
            mov dx, 3F8H		
            mov al, 'r'   
            out dx, al
            call moveBar
            jmp CHECK_TIME
        movebarleft:
            mov dir, 0
            mov Barlr,'1'
            mov dx,3FDH 			
            in al , dx 			
            AND al , 00100000b
            jz right 
            mov dx, 3F8H			
            mov al, 'l'     
            out dx, al
            call moveBar
            jmp CHECK_TIME
right:
    MOV DX, 3FDh	
	in AL, DX		
	AND al, 1
	JZ next	
    MOV DX, 03F8h
	in al, dx
    cmp al, 'l'
    jz rmovebarleft
    cmp al, 'r'
    jz rmovebarright
    mov ah, 4Ch
    int 21h
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