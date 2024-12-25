public DRAW_BALL
public MOVE_BALL
public Clear_BALL
public Bllr
public Lives
public rLives

extrn startColumn:word
extrn startRow:word
extrn endColumn:word
extrn endRow:word

extrn rstartColumn:word
extrn rstartRow:word
extrn rendColumn:word
extrn rendRow:word


.model small

.stack 100h


.data
	Bllr db '1'
	WINDOW_WIDTH equ 140h ; 320 pixels width of the window
	WINDOW_HEIGHT equ 1E0h ; 200 pixels height of the window
	reverse_direction db -1


	BALL_X dw 0A0h
	BALL_Y dw 0F0h
	BALL_SIZE dw 06h	; 4x4 pixels
	BALL_VELOCITY_X dw 6h
	BALL_VELOCITY_Y dw 6h
	BALL_ORIGINAL_X dw 0A0h
 	BALL_ORIGINAL_Y dw 0F0h

	BRICK_X_START dw ?
	BRICK_Y_START dw ?
	BRICK_X_END dw ?
	BRICK_Y_END dw ?
	BRICK_IX dw ?
	BRICK_IY dw ?
	Lives db 3

	rWINDOW_WIDTH equ 280h ; 320 pixels width of the window
	rWINDOW_HEIGHT equ 1E0h ; 200 pixels height of the window
	rreverse_direction db -1


	rBALL_X dw 480
	rBALL_Y dw 0F0h
	rBALL_SIZE dw 06h	; 4x4 pixels
	rBALL_VELOCITY_X dw 6h
	rBALL_VELOCITY_Y dw 6h
	rBALL_ORIGINAL_X dw 480
 	rBALL_ORIGINAL_Y dw 0F0h

	rBRICK_X_START dw ?
	rBRICK_Y_START dw ?
	rBRICK_X_END dw ?
	rBRICK_Y_END dw ?
	rBRICK_IX dw ?
	rBRICK_IY dw ?
	rLives db 3
.code

DRAW_BALL proc near

	cmp Bllr,'1'
	jnz right1
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

right1:
	mov cx, rBALL_X	; initial x position
	mov dx, rBALL_Y	; initial y position

	rrowLoopB:
		mov ah, 0Ch	; set pixel
		mov al, 0Fh	; color
		mov bl, 00h	; page number
		int 10h

		inc cx
		mov ax, cx
		sub ax, rBALL_X
		cmp ax, rBALL_SIZE
		jl rrowLoopB
		
		mov cx, rBALL_X	; reset x position
		inc dx
		mov ax, dx
		sub ax, rBALL_Y
		cmp ax, rBALL_SIZE
		jl rrowLoopB
	ret

DRAW_BALL endp

RESTART_BALL_POSITION proc far
	cmp Bllr , '1'
	jnz right2
	MOV AX,BALL_ORIGINAL_X
	MOV BALL_X,AX

	MOV AX,BALL_ORIGINAL_Y
	MOV BALL_Y,AX
	sub Lives,1
	ret
	right2:
	MOV AX,rBALL_ORIGINAL_X
	MOV rBALL_X,AX

	MOV AX,rBALL_ORIGINAL_Y
	MOV rBALL_Y,AX
	sub rLives,1
	ret

RESTART_BALL_POSITION endp


Clear_BALL proc near
	cmp Bllr , '1'
	jnz right3
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
	right3:
	mov cx, rBALL_X	; initial x position
	mov dx, rBALL_Y	; initial y position

	rlocalRowLoop:
		mov ah, 0Ch	; set pixel
		mov al, 00h	; color
		mov bl, 00h	; page number
		int 10h

		inc cx
		mov ax, cx
		sub ax, rBALL_X
		cmp ax, rBALL_SIZE
		jl rlocalRowLoop
		
		mov cx, rBALL_X	; reset x position
		inc dx
		mov ax, dx
		sub ax, rBALL_Y
		cmp ax, rBALL_SIZE
		jl rlocalRowLoop

		ret

Clear_BALL endp

eraseBrick PROC FAR
	cmp Bllr, '1'
	jnz right4
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
	right4:
	mov cx,rBRICK_X_START 
	mov dx,rBRICK_Y_START  
	mov al,0 
	mov ah,0ch 
	rdrawVerticalB: 
		rdrawHorizontalLineB:
			int 10h
			inc cx
			cmp rBRICK_X_END, cx
			jnz rdrawHorizontalLineB
		mov cx, rBRICK_X_START
		inc dx
		cmp rBRICK_Y_END,dx
		jnz rdrawVerticalB
	ret
eraseBrick ENDP

CHECK_Brick_COL proc far
	cmp Bllr, '1'
	jnz bright5
	mov cx, BAll_X
	mov dx, BAll_Y
	mov bh,0
	mov ah,0dh
	int 10h
	cmp al,5h
	jnz done1


	mov ax,BAll_X
	mov cl,64
	div cl
	mov ah,0
	mov BRICK_IX,ax

	mov ax,BAll_Y
	mov cl,15
	div cl
	mov ah,0
	mov BRICK_IY,ax
	jmp cont

bright5:	jmp right5

cont:	mov ax,BRICK_IX
	mov cl,64
	mul cl
	mov BRICK_X_START,ax
	add ax, 64
	mov BRICK_X_END,ax
	mov ax,BRICK_IY
	mov cl,15
	mul cl
	mov BRICK_Y_START,ax
	add ax,15
	mov BRICK_Y_END,ax
	call eraseBrick
	mov ax, BALL_X
	add ax,5
	mov cx, 64
	div cx
	cmp dx,0
	jz MULTIPLY_VELOCITY_X
	mov ax, BALL_X
	sub ax,5
	mov cx, 64
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

		right5:

		mov cx, rBAll_X
	mov dx, rBAll_Y
	mov bh,0
	mov ah,0dh
	int 10h
	cmp al,5h
	jnz rdone1


	mov ax,rBAll_X
	mov cl,64
	div cl
	mov ah,0
	mov rBRICK_IX,ax

	mov ax,rBAll_Y
	mov cl,15
	div cl
	mov ah,0
	mov rBRICK_IY,ax

	mov ax,rBRICK_IX
	mov cl,64
	mul cl
	mov rBRICK_X_START,ax
	add ax, 64
	mov rBRICK_X_END,ax
	mov ax,rBRICK_IY
	mov cl,15
	mul cl
	mov rBRICK_Y_START,ax
	add ax,15
	mov rBRICK_Y_END,ax
	call eraseBrick
	mov ax, rBALL_X
	add ax,5
	mov cx, 64
	div cx
	cmp dx,3
	jz rMULTIPLY_VELOCITY_X
	mov ax, rBALL_X
	sub ax,5
	mov cx, 64
	div cx
	cmp dx,3
	jz rMULTIPLY_VELOCITY_X
	

rMULTIPLY_VELOCITY_Y:
    NEG rBALL_VELOCITY_Y
		mov ax, rBALL_VELOCITY_Y
		add rBALL_Y, ax
		ret

rMULTIPLY_VELOCITY_X:
    NEG rBALL_VELOCITY_X
		mov ax, rBALL_VELOCITY_X
		add rBALL_X, ax
	rdone1:
		ret

CHECK_Brick_COL endp

MOVE_BALL proc far

	cmp Bllr , '1'
	jnz bright6
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
    mov ax,startRow
    cmp BALL_Y, ax
    jle done
		mov ax, endRow
		cmp BALL_Y, ax
		jge done 
    mov ax, startColumn
    cmp BALL_X, ax
    jle done
    mov ax, endColumn
    cmp BALL_X, ax
    jge done
    jmp MULTIPLY_VELOCITY_Y_BY_NEG
	bright6: jmp right6

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

	right6:

	mov ax, rBALL_X
    add ax, rBALL_VELOCITY_X         				; move the ball horizontally
    mov rBALL_X, ax

    cmp rBALL_X, 320
    jl rMULTIPLY_VELOCITY_X_BY_NEG						; BALL_X < 0 => ball collided with left wall
		mov ax, rWINDOW_WIDTH
		sub ax, rBALL_SIZE
    cmp rBALL_X, ax						
    jg rMULTIPLY_VELOCITY_X_BY_NEG

    mov ax, rBALL_Y
    add ax, rBALL_VELOCITY_Y         				; move the ball vertically
    mov rBALL_Y, ax

    cmp rBALL_Y, 00h
    jl rMULTIPLY_VELOCITY_Y_BY_NEG						; BALL_Y < 0 => ball collided with top wall
		mov ax, rWINDOW_HEIGHT
		sub ax, rBALL_SIZE
    cmp rBALL_Y, ax						
    jg rlpl
	
    call CHECK_Brick_COL
    mov ax,rstartRow
    cmp rBALL_Y, ax
    jle rdone
		mov ax, rendRow
		cmp rBALL_Y, ax
		jge rdone 
    mov ax, rstartColumn
    cmp rBALL_X, ax
    jle rdone
    mov ax, rendColumn
    cmp rBALL_X, ax
    jge rdone
    jmp rMULTIPLY_VELOCITY_Y_BY_NEG

rlpl:call RESTART_BALL_POSITION
rdone:
    ret

rMULTIPLY_VELOCITY_X_BY_NEG:
    NEG rBALL_VELOCITY_X
		mov ax, rBALL_VELOCITY_X
		add rBALL_X, ax
    ret

rMULTIPLY_VELOCITY_Y_BY_NEG:
    NEG rBALL_VELOCITY_Y
		mov ax, rBALL_VELOCITY_Y
		add rBALL_Y, ax
    ret

MOVE_BALL endp
end
