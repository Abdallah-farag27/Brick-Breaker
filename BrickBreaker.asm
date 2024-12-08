; ; Pong game in assembly language for DOS

; .model small

; .stack 100h


; .data

; 	WINDOW_WIDTH equ 140h ; 320 pixels width of the window
; 	WINDOW_HEIGHT equ 0c8h ; 200 pixels height of the window
; 	reverse_direction db -1
	
; 	PREV_TIMESTEP db 0 ; previous time step, if it is different than the sysem times' one-hundredth, then we re-draw the ball

; 	BALL_X dw 0A0h
; 	BALL_Y dw 64h
; 	BALL_SIZE dw 04h	; 4x4 pixels
; 	BALL_VELOCITY_X dw 05h
; 	BALL_VELOCITY_Y dw 02h
; 	BALL_ORIGINAL_X dw 0A0h
; 	BALL_ORIGINAL_Y dw 64h

; .code


; DRAW_BALL proc near

; 	mov cx, BALL_X	; initial x position
; 	mov dx, BALL_Y	; initial y position

; 	rowLoop:
; 		mov ah, 0Ch	; set pixel
; 		mov al, 0Fh	; color
; 		mov bl, 00h	; page number
; 		int 10h

; 		inc cx
; 		mov ax, cx
; 		sub ax, BALL_X
; 		cmp ax, BALL_SIZE
; 		jl rowLoop
		
; 		mov cx, BALL_X	; reset x position
; 		inc dx
; 		mov ax, dx
; 		sub ax, BALL_Y
; 		cmp ax, BALL_SIZE
; 		jl rowLoop
; 	ret

; DRAW_BALL endp


; RESTART_BALL_POSITOIN proc near

; 	MOV AX,BALL_ORIGINAL_X
; 	MOV BALL_X,AX

; 	MOV AX,BALL_ORIGINAL_Y
; 	MOV BALL_Y,AX

; 	ret

; RESTART_BALL_POSITOIN endp


; CLEAR_SCREEN proc near

; 	mov ax, 0600h
; 	mov bh, 00h  ; Attribute for clearing (white on black)
; 	mov cx, 0000h ; Upper left corner (row 0, column 0)
; 	mov dx, 184Fh ; Lower right corner (row 24, column 79)
; 	int 10h

; 	ret
; CLEAR_SCREEN endp


; MOVE_BALL proc near

;     mov ax, BALL_X
;     add ax, BALL_VELOCITY_X         				; move the ball horizontally
;     mov BALL_X, ax

;     cmp BALL_X, 00h
;     jl RESET_POSITION						; BALL_X < 0 => ball collided with left wall
; 		mov ax, WINDOW_WIDTH
; 		sub ax, BALL_SIZE
;     cmp BALL_X, ax													; BALL_X > window_width - ball size => ball collided with right wall
;     jg RESET_POSITION

;     mov ax, BALL_Y
;     add ax, BALL_VELOCITY_Y         				; move the ball vertically
;     mov BALL_Y, ax

;     cmp BALL_Y, 00h
;     jl MULTIPLY_VELOCITY_Y_BY_NEG						; BALL_Y < 0 => ball collided with top wall
; 		mov ax, WINDOW_HEIGHT
; 		sub ax, BALL_SIZE
;     cmp BALL_Y, ax													; BALL_Y > window_height - ball size => ball collided with bottom wall
;     jg MULTIPLY_VELOCITY_Y_BY_NEG

;     ret

; RESET_POSITION:
;     call RESTART_BALL_POSITOIN
; 		mov ax, BALL_VELOCITY_X
; 		add BALL_X, ax
;     ret

; MULTIPLY_VELOCITY_Y_BY_NEG:
;     NEG BALL_VELOCITY_Y
; 		mov ax, BALL_VELOCITY_Y
; 		add BALL_Y, ax
;     ret

; MOVE_BALL endp

; 	mov ax, BALL_ORIGINAL_X
; 	mov BALL_X, ax
	
; 	mov ax, BALL_ORIGINAL_Y
; 	mov BALL_Y, ax

; main proc far

;   mov ax,@data
;   mov ds,ax

;   mov ah, 00h	; set video mode
;   mov al, 13h ; 320x200 256 colors
;   int 10h

;   call CLEAR_SCREEN

; 	CHECK_TIME:

; 		mov ah, 2ch ; get the system time
; 		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

; 		cmp dl, PREV_TIMESTEP
; 		jz CHECK_TIME	; if the time hasn't changed, then we don't need to re-draw the ball
; 		MOV PREV_TIMESTEP, DL ; update the previous time step

; 		; Clear the screen
; 		call CLEAR_SCREEN

; 		call MOVE_BALL


; 		call DRAW_BALL

; 		jmp CHECK_TIME

;   mov ah, 4Ch
;   int 21h

; main endp
; end main


; Pong game in assembly language for DOS

.model small

.stack 100h


.data

	WINDOW_WIDTH equ 140h ; 320 pixels width of the window
	WINDOW_HEIGHT equ 0c8h ; 200 pixels height of the window
	reverse_direction db -1
	
	PREV_TIMESTEP db 0 ; previous time step, if it is different than the sysem times' one-hundredth, then we re-draw the ball
	
	BALL_X dw 0A0h
	BALL_Y dw 64h
	BALL_SIZE dw 04h	; 4x4 pixels
	BALL_VELOCITY_X dw 05h
	BALL_VELOCITY_Y dw 02h
	BALL_ORIGINAL_X dw 0A0h
 	BALL_ORIGINAL_Y dw 64h

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

RESTART_BALL_POSITOIN proc near

	MOV AX,BALL_ORIGINAL_X
	MOV BALL_X,AX

	MOV AX,BALL_ORIGINAL_Y
	MOV BALL_Y,AX

	ret

RESTART_BALL_POSITOIN endp


CLEAR_SCREEN proc near

	mov ax, 0600h
	mov bh, 00h  ; Attribute for clearing (white on black)
	mov cx, 0000h ; Upper left corner (row 0, column 0)
	mov dx, 184Fh ; Lower right corner (row 24, column 79)
	int 10h

	ret
CLEAR_SCREEN endp


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
    jg RESTART_BALL_POSITOIN

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


main proc far

  mov ax,@data
  mov ds,ax

  mov ah, 00h	; set video mode
  mov al, 13h ; 320x200 256 colors
  int 10h

  call CLEAR_SCREEN

	CHECK_TIME:

		mov ah, 2ch ; get the system time
		int 21h ; CH = hour, CL = minute, DH = second, DL = 1/100 second

		cmp dl, PREV_TIMESTEP
		jz CHECK_TIME	; if the time hasn't changed, then we don't need to re-draw the ball
		MOV PREV_TIMESTEP, DL ; update the previous time step

		; Clear the screen
		call CLEAR_SCREEN

		call MOVE_BALL


		call DRAW_BALL

		jmp CHECK_TIME

  mov ah, 4Ch
  int 21h

main endp
end main
