
; public DRAW_BALL
; public MOVE_BALL
; public Clear_BALL

; extrn startColumn:word
; extrn startRow:word	
; extrn endColumn:word
; extrn endRow:word

.model small

.stack 100h


.data

	WINDOW_WIDTH equ 280h ; 320 pixels width of the window
	WINDOW_HEIGHT equ 1E0h ; 200 pixels height of the window
	reverse_direction db -1
	
    MAX_HEIGHT equ 120
	
	currWidth Dw 0
	currHeight Dw 0

    brickWidth dw 128
    brickHeight dw 30

    colorBlack db 16
    colorGray db 7

    ; colorB db 0
    currColor db 7
    temp dw ?

    tmpWidth dw ?
    tmpHeight dw ?

	color       db 7h
    startColumn dw 240 
    endColumn   dw 400
    startRow    dw 400 
    endRow      dw 420 
    wide        dw 160
    height      dw 20
    barSpeed    dw 20
    tempVar1    dw ?
    tempVar2    dw ?
    dir         db ?

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
	PREV_TIMESTEP db 0 ; previous time step, if it is different than the sysem times' one-hundredth, then we re-draw the ball
.code


DRAW_BALL proc near

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

DRAW_BALL endp

RESTART_BALL_POSITION proc near

	MOV AX,BALL_ORIGINAL_X
	MOV BALL_X,AX

	MOV AX,BALL_ORIGINAL_Y
	MOV BALL_Y,AX

	ret

RESTART_BALL_POSITION endp


Clear_BALL proc near
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
Clear_BALL endp

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
	cmp al,7
	jnz done1

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
MULTIPLY_VELOCITY_Y:
    NEG BALL_VELOCITY_Y
		mov ax, BALL_VELOCITY_Y
		add BALL_Y, ax
	done1:
		ret
CHECK_Brick_COL endp

MOVE_BALL proc near

    mov ax, BALL_X
    add ax, BALL_VELOCITY_X         				; move the ball horizontally
    mov BALL_X, ax

    cmp BALL_X, 00h
    jl MULTIPLY_VELOCITY_X_BY_NEG						; BALL_X < 0 => ball collided with left wall
		mov ax, WINDOW_WIDTH
		sub ax, BALL_SIZE
    cmp BALL_X, ax							; BALL_X > window_width - ball size => ball collided with right wall
    jg MULTIPLY_VELOCITY_X_BY_NEG

    mov ax, BALL_Y
    add ax, BALL_VELOCITY_Y         				; move the ball vertically
    mov BALL_Y, ax

    cmp BALL_Y, 00h
    jl MULTIPLY_VELOCITY_Y_BY_NEG						; BALL_Y < 0 => ball collided with top wall
		mov ax, WINDOW_HEIGHT
		sub ax, BALL_SIZE
    cmp BALL_Y, ax							; BALL_Y > window_height - ball size => ball collided with bottom wall
    jg RESTART_BALL_POSITION

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

MOVE_BALL endp
IncWHC proc far
    mov ax ,brickWidth
    add currWidth ,ax
    
    mov ax,WINDOW_WIDTH
    cmp ax,currWidth 
    jnz ENDPROC
    mov currWidth,0
    
    mov ax,brickHeight
    add currHeight,ax

ENDPROC:
    ret 
IncWHC endp

ChooseColor proc far
    push cx
    mov bp ,tmpWidth
    mov cx ,tmpHeight

    cmp bp,currWidth
    jz changeToBlack
    cmp cx,currHeight
    jz changeToBlack

    mov ax,currWidth
    add ax,brickWidth
    cmp bp,ax
    jz changeToBlack

    mov ax,currHeight
    add ax,brickHeight
    cmp cx,ax
    jz changeToBlack

changeToGray:
    mov al,colorGray
    mov currColor,al
    pop cx
    ret
changeToBlack:
    mov al,colorBlack
    mov currColor,al
    pop cx
    ret 
ChooseColor endp

DrawBrick proc far
    
    mov si, currWidth    
    mov di, currHeight

DrawColoumn:
    mov bx, brickHeight      ; Rectangle width
    mov dx, di      ; Start X coordinate

DrawRow:
    ; INT 10h Function 0Ch - Write Pixel
    mov tmpHeight,dx
    mov tmpWidth,cx
    call ChooseColor
    mov cx,si
    mov al,currColor
    mov ah, 0Ch     ; Write pixel to screen
    int 10h         ; Draw pixel at (DX, SI)
    
    inc dx          ; Next pixel in row
    dec bx 
    jnz DrawRow
    
    inc si          ; Move to next row
    mov ax,brickWidth
    add ax,currWidth
    cmp ax,si
    jnz DrawColoumn

    ret
DrawBrick endp

Bricks proc far


    

DrawBricks:
    call DrawBrick
    call IncWHC
    mov ax,MAX_HEIGHT
    cmp ax, currHeight
    jz ENDsss
    jmp DrawBricks

ENDsss:    
  
ret
Bricks endp

drawBar PROC FAR
    mov cx,startColumn 
    mov dx,startRow  
    mov al,color 
    mov ah,0ch 
    drawVertical: 
        drawHorizontalLine:
            int 10h
            inc cx
            cmp cx, endColumn
            jnz drawHorizontalLine
        mov cx, startColumn
        inc dx
        cmp dx, endRow
        jnz drawVertical
    ret
drawBar ENDP

moveBar PROC FAR
    cmp dir,0
    jnz rightDraw
    leftDraw:
        cmp startColumn,1
        jb endMove
        mov cx, startColumn
        mov tempVar1,cx
        mov dx, barSpeed
        sub cx, dx
        mov startColumn,cx
        mov tempVar2,cx
        mov dx, startRow
        jmp draw
    rightDraw:
        cmp endColumn, 639
        ja endMove
        mov cx, endColumn
        mov tempVar1,cx
        mov tempVar2,cx
        mov dx, barSpeed
        add tempVar1,dx
        add endColumn,dx
        mov dx, startRow
        jmp draw
    endMove:
        mov color,7h
        ret
    draw:
        mov al,color
        mov ah,0ch
        drawVerticalmove: 
            drawHorizontalmove:
                int 10h
                inc cx
                cmp cx, tempVar1
                jnz drawHorizontalmove
            mov cx, tempVar2
            inc dx
            cmp dx, endRow
            jnz drawVerticalmove
        cmp color,0
        jz endMove
        cmp dir, 0
        jz leftErase
        cmp dir, 1
        jz rightErase
    leftErase:
        mov cx, endColumn
        mov tempVar1,cx
        sub cx,barSpeed
        mov tempVar2,cx
        mov endColumn,cx
        mov dx, startRow
        mov color,0
        jmp draw
    rightErase:
        mov cx, startColumn
        mov tempVar2,cx
        mov dx,barSpeed
        mov tempVar1,cx
        add tempVar1,dx
        add startColumn,dx
        mov dx, startRow
        mov color,0
        jmp draw
moveBar ENDP

main proc far
	mov ax, @data
	mov ds, ax
	 mov ax,12h
    int 10h
    call Bricks
CHECK_TIME:

		mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	; if the time hasn't changed, then we don't need to re-draw the ball
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

main endp
end main

; Bdraw proc far

;   ; mov ah, 00h	; set video mode
;   ; mov al, 12h ; 320x200 256 colors
;   ; int 10h

;   ; mov ax, 0600h
; 	; mov bh, 00h  ; Attribute for clearing (white on black)
; 	; mov cx, 0000h ; Upper left corner (row 0, column 0)
; 	; mov dx, 184Fh ; Lower right corner (row 24, column 79)
; 	; int 10h
	
; 	CHECK_TIME:

; 		mov ah, 2ch ; get the system time
; 		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

; 		cmp dl, PREV_TIMESTEP
; 		jz CHECK_TIME	; if the time hasn't changed, then we don't need to re-draw the ball
; 		MOV PREV_TIMESTEP, DL ; update the previous time step

; 		; Clear the screen
; 		call Clear_BALL

; 		call MOVE_BALL


; 		call DRAW_BALL

; 		jmp CHECK_TIME
; ret

; Bdraw endp
end
