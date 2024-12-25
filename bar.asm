public moveBar
public drawBar

public dir
public startColumn
public startRow
public endColumn
public endRow

public rdir
public rstartColumn
public rstartRow
public rendColumn
public rendRow

public Barlr
public ResetBar
public RESIZEbar
.model small
.stack 100h
.data
    Barlr db '1'
    color       db 3h
    startColumn dw 120
    endColumn   dw 200
    startRow    dw 400 
    endRow      dw 415 
    wide        dw 80
    height      dw 15
    barSpeed    dw 20
    tempVar1    dw ?
    tempVar2    dw ?
    dir         db ?


    rcolor       db 3h
    rstartColumn dw 440
    rendColumn   dw 520
    rstartRow    dw 400 
    rendRow      dw 415 
    rwide        dw 80
    rheight      dw 15
    rbarSpeed    dw 20
    rtempVar1    dw ?
    rtempVar2    dw ?
    rdir         db ?
.code

;description
ResetBar PROC
    mov startColumn , 120
    mov endColumn   , 200
    mov rstartColumn , 440
    mov rendColumn   , 520
    ret
ResetBar ENDP


RESIZEbar proc
    cmp Barlr,'1'
    jnz fady
    cmp startColumn,20
    jl addend1
    sub startColumn,20
    jmp asdasd
    addend1:
    add endColumn,20
    jmp asdasd

    fady:
    cmp rstartColumn,20
    jl addend2
    sub rstartColumn,20
    jmp asdasd
    addend2:
    add rendColumn,20
asdasd:

RESIZEbar endp

drawBar PROC FAR
    cmp Barlr,'1'
    jnz right1
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
    right1:
        mov cx,rstartColumn 
        mov dx,rstartRow  
        mov al,rcolor 
        mov ah,0ch 
        rdrawVertical: 
            rdrawHorizontalLine:
                int 10h
                inc cx
                cmp cx, rendColumn
                jnz rdrawHorizontalLine
            mov cx, rstartColumn
            inc dx
            cmp dx, rendRow
            jnz rdrawVertical
        ret
drawBar ENDP

moveBar PROC FAR

    cmp Barlr,'1'
    jnz Bright2
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
        cmp endColumn, 319
        ja endMove
        mov cx, endColumn
        mov tempVar1,cx
        mov tempVar2,cx
        mov dx, barSpeed
        add tempVar1,dx
        add endColumn,dx
        mov dx, startRow
        jmp draw
        Bright2: jmp right2
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

    right2:
        cmp rdir,0
        jnz rrightDraw
        rleftDraw:
            cmp rstartColumn,322
            jb rendMove
            mov cx, rstartColumn
            mov rtempVar1,cx
            mov dx, rbarSpeed
            sub cx, dx
            mov rstartColumn,cx
            mov rtempVar2,cx
            mov dx, rstartRow
            jmp rdraw
        rrightDraw:
            cmp rendColumn, 639
            ja rendMove
            mov cx, rendColumn
            mov rtempVar1,cx
            mov rtempVar2,cx
            mov dx, rbarSpeed
            add rtempVar1,dx
            add rendColumn,dx
            mov dx, rstartRow
            jmp rdraw
        rendMove:
            mov rcolor,3h
            ret
        rdraw:
            mov al,rcolor
            mov ah,0ch
            rdrawVerticalmove: 
                rdrawHorizontalmove:
                    int 10h
                    inc cx
                    cmp cx, rtempVar1
                    jnz rdrawHorizontalmove
                mov cx, rtempVar2
                inc dx
                cmp dx, rendRow
                jnz rdrawVerticalmove
            cmp rcolor,0
            jz rendMove
            cmp rdir, 0
            jz rleftErase
            cmp rdir, 1
            jz rrightErase
        rleftErase:
            mov cx, rendColumn
            mov rtempVar1,cx
            sub cx,rbarSpeed
            mov rtempVar2,cx
            mov rendColumn,cx
            mov dx, rstartRow
            mov rcolor,0
            jmp rdraw
        rrightErase:
            mov cx, rstartColumn
            mov rtempVar2,cx
            mov dx,rbarSpeed
            mov rtempVar1,cx
            add rtempVar1,dx
            add rstartColumn,dx
            mov dx, rstartRow
            mov rcolor,0
            jmp rdraw
moveBar ENDP

end