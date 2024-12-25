public Bricks
; public WINDOW_WIDTH
; public START_X
; public currWidth
public Brlr
public ResetBrick

.model small

.stack 100h

.data
    Brlr db '1'

    brickWidth dw 64
    brickHeight dw 15

    colorBlack equ 16
    colorGray equ 5

	WINDOW_WIDTH equ 320  ; 640 pixels width of the window
	WINDOW_HEIGHT equ 480 ; 480 pixels height of the window
    MAX_HEIGHT equ 60
    START_X equ 0
	
	currWidth dw 0
	currHeight Dw 0

    currColor db 5
    ; temp dw ?

    tmpWidth dw ?
    tmpHeight dw ?

    rWINDOW_WIDTH equ 640  ; 640 pixels width of the window
	rWINDOW_HEIGHT equ 480 ; 480 pixels height of the window
    rMAX_HEIGHT equ 60
    rSTART_X equ 320
	
	rcurrWidth dw 320
	rcurrHeight Dw 0

    rcurrColor db 5
    ; temp dw ?

    rtmpWidth dw ?
    rtmpHeight dw ?

    
.code
ResetBrick PROC
    mov currWidth,0
    mov currHeight,0
    mov rcurrWidth,320
    mov rcurrHeight,0

    mov rcurrColor , 5
    mov currColor , 5

    mov Brlr ,'1'
    ret
ResetBrick ENDP

IncWHC proc far
    cmp Brlr,'1'
    jnz right1
    mov ax ,brickWidth
    add currWidth ,ax
    
    mov ax,WINDOW_WIDTH
    cmp ax,currWidth 
    jnz ENDPROC
    mov currWidth,START_X
    
    mov ax,brickHeight
    add currHeight,ax
    ret

    right1:
     mov ax ,brickWidth
    add rcurrWidth ,ax
    
    mov ax,rWINDOW_WIDTH
    cmp ax,rcurrWidth 
    jnz ENDPROC
    mov rcurrWidth,rSTART_X
    
    mov ax,brickHeight
    add rcurrHeight,ax

ENDPROC:
    ret 
IncWHC endp

ChooseColor proc far
cmp Brlr,'1'
    jnz right2
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
    mov currColor,colorGray
    pop cx
    ret
changeToBlack:
    mov currColor,colorBlack
    pop cx
    ret


    right2:
    push cx
    mov bp ,rtmpWidth
    mov cx ,rtmpHeight

    cmp bp,rcurrWidth
    jz rchangeToBlack
    cmp cx,rcurrHeight
    jz rchangeToBlack

    mov ax,rcurrWidth
    add ax,brickWidth
    cmp bp,ax
    jz rchangeToBlack

    mov ax,rcurrHeight
    add ax,brickHeight
    cmp cx,ax
    jz rchangeToBlack

rchangeToGray:
    mov rcurrColor,colorGray
    pop cx
    ret
rchangeToBlack:
    mov rcurrColor,colorBlack
    pop cx
    ret  
ChooseColor endp

DrawBrick proc far
    cmp Brlr,'1'
    jnz right3
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
    right3:
    mov si, rcurrWidth    
    mov di, rcurrHeight

rDrawColoumn:
    mov bx, brickHeight      ; Rectangle width
    mov dx, di      ; Start X coordinate

rDrawRow:
    ; INT 10h Function 0Ch - Write Pixel
    mov rtmpHeight,dx
    mov rtmpWidth,cx
    call ChooseColor
    mov cx,si
    mov al,rcurrColor
    mov ah, 0Ch     ; Write pixel to screen
    int 10h         ; Draw pixel at (DX, SI)
    
    inc dx          ; Next pixel in row
    dec bx 
    jnz rDrawRow
    
    inc si          ; Move to next row
    mov ax,brickWidth
    add ax,rcurrWidth
    cmp ax,si
    jnz rDrawColoumn

    ret

DrawBrick endp

Bricks proc far


    

DrawBricks:
    call DrawBrick
    call IncWHC
    cmp Brlr,'1'
    jnz right4
    mov ax,MAX_HEIGHT
    cmp ax, currHeight
    jz ENDsss
    jmp DrawBricks

ENDsss:    
  
ret
right4:
mov ax,rMAX_HEIGHT
    cmp ax, rcurrHeight
    jz rENDsss
    jmp DrawBricks

rENDsss:    
  
ret

Bricks endp

end
