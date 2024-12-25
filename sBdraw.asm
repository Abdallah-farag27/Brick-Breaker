
public sDRAW_BALL
public sMOVE_BALL
public sClear_BALL
public ResetsBdraw
public sLives
public sScore1
public sScore2
public sTotScore

extrn RESIZE:far
extrn sstartColumn:word
extrn sstartRow:word	
extrn sendColumn:word
extrn sendRow:word

.model small

.stack 100h


.data

	WINDOW_WIDTH equ 280h ; 320 pixels width of the window
	WINDOW_HEIGHT equ 1E0h ; 200 pixels height of the window
	reverse_direction db -1


	BALL_X dw 140h
	BALL_Y dw 0F0h
	BALL_SIZE dw 08h	; 4x4 pixels
	BALL_VELOCITY_X dw 8h
	BALL_VELOCITY_Y dw 5h
	BALL_ORIGINAL_X dw 140h
 	BALL_ORIGINAL_Y dw 0F0h

    BRICK_X_START dw ?
    BRICK_Y_START dw ?
    BRICK_X_END dw ?
    BRICK_Y_END dw ?
	BRICK_IX dw ?
	BRICK_IY dw ?
	sLives db 3
	sScore1 db 0
	sScore2 db 0
	sTotScore db 0
	
.code

;description
ResetsBdraw PROC
	mov BALL_X , 140h
	mov BALL_Y , 0F0h
	mov sLives , 3
	mov BALL_VELOCITY_X , 8h
	mov BALL_VELOCITY_Y , 5h
	mov sScore1, 0
	mov sScore2, 0
	mov sTotScore, 0
ResetsBdraw ENDP

sDRAW_BALL proc near

	mov cx, BALL_X	; initial x position
	mov dx, BALL_Y	; initial y position

	rowLoop:
		mov ah, 0Ch	; set pixel
		mov al, 0Fh	; color
		mov bl, 00h	; page number
		int 10h

		inc cx
		mov ax, cx
		sub ax, BALL_X
		cmp ax, BALL_SIZE
		jl rowLoop
		
		mov cx, BALL_X	; reset x position
		inc dx
		mov ax, dx
		sub ax, BALL_Y
		cmp ax, BALL_SIZE
		jl rowLoop
	ret

sDRAW_BALL endp

RESTART_BALL_POSITION proc far

	MOV AX,BALL_ORIGINAL_X
	MOV BALL_X,AX

	MOV AX,BALL_ORIGINAL_Y
	MOV BALL_Y,AX
	sub sLives,1
	ret

RESTART_BALL_POSITION endp


sClear_BALL proc near
	mov cx, BALL_X	; initial x position
	mov dx, BALL_Y	; initial y position

	localRowLoop:
		mov ah, 0Ch	; set pixel
		mov al, 00h	; color
		mov bl, 00h	; page number
		int 10h

		inc cx
		mov ax, cx
		sub ax, BALL_X
		cmp ax, BALL_SIZE
		jl localRowLoop
		
		mov cx, BALL_X	; reset x position
		inc dx
		mov ax, dx
		sub ax, BALL_Y
		cmp ax, BALL_SIZE
		jl localRowLoop
	

	ret
sClear_BALL endp

eraseBrick PROC FAR
	add sTotScore,1
	add sScore1 , 1
	cmp sScore1,10
	jnz cont
	mov sScore1, 0
	add sScore2, 1
cont:    
	mov cx,BRICK_X_START 
    mov dx,BRICK_Y_START  
    mov al,0 
    mov ah,0ch 
    drawVerticalB: 
        drawHorizontalLineB:
            int 10h
            inc cx
            cmp BRICK_X_END, cx
            jnz drawHorizontalLineB
        mov cx, BRICK_X_START
        inc dx
        cmp BRICK_Y_END,dx
        jnz drawVerticalB
    ret
eraseBrick ENDP

CHECK_Brick_COL proc far
	mov cx, BAll_X
	mov dx, BAll_Y
	mov bh,0
	mov ah,0dh
	int 10h
	cmp al,0Eh
	jnz col1
	call RESIZE
	jmp asd
col1:
	cmp al,5h
	jnz done1

asd:
	mov ax,BAll_X
	mov cl,128
	div cl
	mov ah,0
	mov BRICK_IX,ax

	mov ax,BAll_Y
	mov cl,30
	div cl
	mov ah,0
	mov BRICK_IY,ax

	mov ax,BRICK_IX
	mov cl,128
	mul cl
	mov BRICK_X_START,ax
	add ax, 128
	mov BRICK_X_END,ax
	mov ax,BRICK_IY
	mov cl,30
	mul cl
	mov BRICK_Y_START,ax
	add ax,30
	mov BRICK_Y_END,ax
	call eraseBrick
	mov ax, BALL_X
	add ax,8
	mov cx, 128
	div cx
	cmp dx,0
	jz MULTIPLY_VELOCITY_X
	mov ax, BALL_X
	sub ax,8
	mov cx, 128
	div cx
	cmp dx,0
	jz MULTIPLY_VELOCITY_X
	

MULTIPLY_VELOCITY_Y:
    NEG BALL_VELOCITY_Y
		mov ax, BALL_VELOCITY_Y
		add BALL_Y, ax
		ret

MULTIPLY_VELOCITY_X:
    NEG BALL_VELOCITY_X
		mov ax, BALL_VELOCITY_X
		add BALL_X, ax
	done1:
		ret

CHECK_Brick_COL endp

sMOVE_BALL proc far

    mov ax, BALL_X
    add ax, BALL_VELOCITY_X         				; move the ball horizontally
    mov BALL_X, ax

    cmp BALL_X, 00h
    jl MULTIPLY_VELOCITY_X_BY_NEG						; BALL_X < 0 => ball collided with left wall
		mov ax, WINDOW_WIDTH
		sub ax, BALL_SIZE
    cmp BALL_X, ax						
    jg MULTIPLY_VELOCITY_X_BY_NEG

    mov ax, BALL_Y
    add ax, BALL_VELOCITY_Y         				; move the ball vertically
    mov BALL_Y, ax

    cmp BALL_Y, 00h
    jl MULTIPLY_VELOCITY_Y_BY_NEG						; BALL_Y < 0 => ball collided with top wall
		mov ax, WINDOW_HEIGHT
		sub ax, BALL_SIZE
    cmp BALL_Y, ax						
    jg lpl 
	
    call CHECK_Brick_COL
    mov ax,sstartRow
    cmp BALL_Y, ax
    jle done
	mov ax, sendRow
	cmp BALL_Y, ax
	jge done 
    mov ax, sstartColumn
    cmp BALL_X, ax
    jle done
    mov ax, sendColumn
    cmp BALL_X, ax
    jge done
    jmp MULTIPLY_VELOCITY_Y_BY_NEG

lpl:call RESTART_BALL_POSITION
done:
    ret

MULTIPLY_VELOCITY_X_BY_NEG:
    NEG BALL_VELOCITY_X
		mov ax, BALL_VELOCITY_X
		add BALL_X, ax
    ret

MULTIPLY_VELOCITY_Y_BY_NEG:
    NEG BALL_VELOCITY_Y
		mov ax, BALL_VELOCITY_Y
		add BALL_Y, ax
    ret

sMOVE_BALL endp
end
