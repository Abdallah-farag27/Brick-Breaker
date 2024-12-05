; setCursor macro x, y
;     mov ah,2
;     mov dl,x
;     mov dh,y
;     int 10h
; ENDM

.model small
.stack 100h
.data
    color  db 7h
    startColumn dw 99 
    endColumn   dw 219 
    startRow    dw 175 
    endRow      dw 185 
    wide        dw 120
    height      dw 10
.code
; procedure PROC FAR
    
;     ret
; ENDP

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


main proc far
    mov ax, @data
    mov ds, ax
    mov ah,0
    mov al,4
    int 10h
    call drawBar
   
    mov ah, 4Ch     	
    int 21h
main endp
end main