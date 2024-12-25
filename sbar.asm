public smoveBar
public sdir
public sdrawBar
public sstartColumn
public sstartRow
public sendColumn
public sendRow
public ResetsBar
public RESIZE
.model small
.stack 100h
.data
    color       db 3h
    sstartColumn dw 240 
    sendColumn   dw 400
    sstartRow    dw 400 
    sendRow      dw 420 
    wide        dw 160
    height      dw 20
    barSpeed    dw 20
    tempVar1    dw ?
    tempVar2    dw ?
    sdir         db ?
.code
ResetsBar PROC
    mov sstartColumn , 240
    mov sendColumn   , 400
    ret
ResetsBar ENDP

RESIZE proc
    cmp sstartColumn,40
    jl addend
    sub sstartColumn,40
    addend:
    add sendColumn,40
RESIZE endp

sdrawBar PROC FAR
    mov cx,sstartColumn 
    mov dx,sstartRow  
    mov al,color 
    mov ah,0ch 
    drawVertical: 
        drawHorizontalLine:
            int 10h
            inc cx
            cmp cx, sendColumn
            jnz drawHorizontalLine
        mov cx, sstartColumn
        inc dx
        cmp dx, sendRow
        jnz drawVertical
    ret
sdrawBar ENDP

smoveBar PROC FAR
    cmp sdir,0
    jnz rightDraw
    leftDraw:
        cmp sstartColumn,1
        jb endMove
        mov cx, sstartColumn
        mov tempVar1,cx
        mov dx, barSpeed
        sub cx, dx
        mov sstartColumn,cx
        mov tempVar2,cx
        mov dx, sstartRow
        jmp draw
    rightDraw:
        cmp sendColumn, 639
        ja endMove
        mov cx, sendColumn
        mov tempVar1,cx
        mov tempVar2,cx
        mov dx, barSpeed
        add tempVar1,dx
        add sendColumn,dx
        mov dx, sstartRow
        jmp draw
    endMove:
        mov color,3h
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
            cmp dx, sendRow
            jnz drawVerticalmove
        cmp color,0
        jz endMove
        cmp sdir, 0
        jz leftErase
        cmp sdir, 1
        jz rightErase
    leftErase:
        mov cx, sendColumn
        mov tempVar1,cx
        sub cx,barSpeed
        mov tempVar2,cx
        mov sendColumn,cx
        mov dx, sstartRow
        mov color,0
        jmp draw
    rightErase:
        mov cx, sstartColumn
        mov tempVar2,cx
        mov dx,barSpeed
        mov tempVar1,cx
        add tempVar1,dx
        add sstartColumn,dx
        mov dx, sstartRow
        mov color,0
        jmp draw
smoveBar ENDP

; barDraw proc far
;     ; mov ah,0
;     ; mov al,12h
;     ; int 10h
;     call sdrawBar
;    check: mov ah,1
;     int 16h
;     jz next
;     mov ah,0
;     int 16h
;     cmp ah, 4Bh
;     jz smovebarleft
;     cmp ah, 4Dh
;     jz smovebarright

;     next:
;     ;rest of code
;         jmp check
;     smovebarright:
;         mov sdir, 1
;         call smoveBar
;         jmp check
;     smovebarleft:
;         mov sdir, 0
;         call smoveBar
;         jmp check
;     exit:
;     ret
; barDraw endp
end