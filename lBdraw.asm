
public lDRAW_BALL
public lMOVE_BALL
public lClear_BALL

extrn startColumn:word
extrn startRow:word	
extrn endColumn:word
extrn endRow:word

.model small

.stack 100h


.data

	WINDOW_WIDTH equ 280h ; 320 pixels width of the window
	WINDOW_HEIGHT equ 1E0h ; 200 pixels height of the window
	reverse_direction db -1


	BALL_X dw 480
	BALL_Y dw 0F0h
	BALL_SIZE dw 06h	; 4x4 pixels
	BALL_VELOCITY_X dw 9h
	BALL_VELOCITY_Y dw 6h
	BALL_ORIGINAL_X dw 480
 	BALL_ORIGINAL_Y dw 0F0h

  BRICK_X_START dw ?
  BRICK_Y_START dw ?
  BRICK_X_END dw ?
  BRICK_Y_END dw ?
	BRICK_IX dw ?
	BRICK_IY dw ?
	PREV_TIMESTEP db 0 
.code


lDRAW_BALL proc near

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

lDRAW_BALL endp

RESTART_BALL_POSITION proc far

	MOV AX,BALL_ORIGINAL_X
	MOV BALL_X,AX

	MOV AX,BALL_ORIGINAL_Y
	MOV BALL_Y,AX

	ret

RESTART_BALL_POSITION endp


lClear_BALL proc near
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
lClear_BALL endp

eraseBrick PROC FAR
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
	cmp al,5h
	jnz done1


	mov ax,BAll_X
	mov cl,128
	div cl
	mov ah,0
	mov BRICK_IX,ax

	mov ax,BAll_Y
	mov cl,15
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
	cmp dx,2
	jz MULTIPLY_VELOCITY_X
	mov ax, BALL_X
	sub ax,5
	mov cx, 64
	div cx
	cmp dx,2
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

lMOVE_BALL proc far

    mov ax, BALL_X
    add ax, BALL_VELOCITY_X         				; move the ball horizontally
    mov BALL_X, ax

    cmp BALL_X, 320
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

lMOVE_BALL endp
end
