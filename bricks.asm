public Bricks

.model small

.stack 100h

.data

	WINDOW_WIDTH equ 320  ; 640 pixels width of the window
	WINDOW_HEIGHT equ 480 ; 480 pixels height of the window
    MAX_HEIGHT equ 60
    START_X equ 0
	
	currWidth Dw 0
	currHeight Dw 0

    brickWidth dw 64
    brickHeight dw 15

    colorBlack db 16
    colorGray db 5

    color db 0
    currColor db 5
    temp dw ?

    tmpWidth dw ?
    tmpHeight dw ?
.code

IncWHC proc far
    mov ax ,brickWidth
    add currWidth ,ax
    
    mov ax,WINDOW_WIDTH
    cmp ax,currWidth 
    jnz ENDPROC
    mov currWidth,START_X
    
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

end
