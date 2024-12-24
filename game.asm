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
    ; mov ax, @data
    ; mov ds, ax
    mov ax,12h
    int 10h
    mov Brlr,'1'
    call Bricks
    mov Brlr,'0'
    call Bricks
    ; mov startColumn, 120
    ; mov endColumn, 200
             
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
        
        mov Barlr,'1'
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