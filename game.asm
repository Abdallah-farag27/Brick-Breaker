public game

extrn Bricks:FAR 
extrn bDraw:far
extrn barDraw:far
.model small

.stack 100h
.data


.code

game proc far
    ; mov ax, @data
    ; mov ds, ax
    mov ax,12h
    int 10h
    call Bricks
    call bDraw
    call barDraw
lbl: jmp lbl
    ; mov ah, 4Ch
    ; int 21h
    ret

game endp
end