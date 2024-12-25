Public quit
Public WorL

moveCursor macro row,col
               mov ah,02h
               mov dh,row
               mov dl,col
               mov bh,0
               int 10h
endm

DisplayString MACRO STR
                  lea dx,STR
                  mov ah,09h
                  int 21h
ENDM

ClearScreen macro
                mov ah,06h
                mov al,0
                mov bh,07h
                mov cx,0
                mov dh,25
                mov dl,80
                int 10h
endm

changeArrow macro x,y
                moveCursor    12, 25
                DisplayString deleteArrow
                moveCursor    14, 25
                DisplayString deleteArrow
                moveCursor    x, y
                DisplayString arrow
                moveCursor    24, 78
                DisplayString deleteArrow
                jmp           again
endm

ExitProgram MACRO
                mov ah, 4Ch
                int 21h
ENDM

.model small
.stack 100h
.data
    WorL db '0'
    Win db'You Win!','$'
    Cong      db 'Congratulation','$'
    Lose db'You Lose!','$'
    GameOver      db 'Game Over','$'
    Back     db 'Back To Main Menu','$'
    Exit          db 'Exit The Game','$'
    arrow         db 10h,'$'
    deleteArrow   db ' ','$'
    currentOption db 0
.code

quit proc far
             mov           ax, @data
             mov           ds, ax

 mov ax,3h
    int 10h
             ClearScreen


             moveCursor    6, 34
             cmp WorL, '1'
             jnz  lbl1
             DisplayString Win
             jmp cont1
    lbl1:    DisplayString Lose
    cont1:   cmp WorL, '1'
             jnz  lbl2
             moveCursor    8, 32
             DisplayString cong
             jmp cont2
    lbl2:
             moveCursor    8, 34
             DisplayString GameOver
    cont2:   moveCursor    12, 30
             DisplayString Back
             moveCursor    14, 32
             DisplayString exit
             changeArrow   12, 25

    again:   mov           ah, 0               ; BIOS function to read key press
             int           16h                 ; Call BIOS interrupt

             cmp           ah, 50h             ; Check if AH contains the scan code for the down arrow
             jz            down                ; Jump to down arrow handling

             cmp           ah, 48h             ; Check if AH contains the scan code for the up arrow
             jz            dummy1              ; Jump to up arrow handling

             cmp           al, 0Dh             ; Check for Enter key (scan code for Enter)
             jz            check               ; Exit if Enter is pressed

             jmp           again               ; Loop back if no recognized key is pressed

    check:   
             ClearScreen
             cmp           currentOption,0
             jnz           p2
            ExitProgram;;;;;;;;;;;;;;;;;;;;;;;;
      p2:        ExitProgram

    dummy1:  jmp            up
    down:    cmp           currentOption, 1
             jnz           downcont
             mov           currentOption, 0
             changeArrow   12, 25
    downcont:inc           currentOption
             changeArrow   14, 25

    up:      cmp           currentOption, 0
             jnz           upcont
             mov           currentOption, 1
             changeArrow   14, 25

    upcont:  dec           currentOption
             changeArrow   12, 25
             ret
quit endp
end