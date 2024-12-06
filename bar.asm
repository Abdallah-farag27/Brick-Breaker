
.model huge
.stack 100h
.data
    color       db 7h
    startColumn dw 99 
    endColumn   dw 219 
    startRow    dw 175 
    endRow      dw 185 
    wide        dw 120
    height      dw 10
    barSpeed    dw 2
    tempVar1    dw ?
    tempVar2    dw ?
    dir         db ?
.code

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
ENDP

moveBar PROC FAR
    cmp dir,0
    jnz rightDraw
    leftDraw:
        cmp startColumn,2
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
        cmp endColumn,318
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
ENDP

main proc far
    mov ax, @data
    mov ds, ax
    mov ah,0
    mov al,4
    int 10h
    call drawBar
   check: mov ah,1
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
        jmp check
    movebarright:
        mov dir, 1
        call moveBar
        jmp check
    movebarleft:
        mov dir, 0
        call moveBar
        jmp check
    exit:
        mov ah, 4Ch     	
        int 21h
main endp
end main