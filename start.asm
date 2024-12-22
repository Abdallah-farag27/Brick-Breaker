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
                moveCursor    12,25
                DisplayString deleteArrow
                moveCursor    14, 25
                DisplayString deleteArrow
                moveCursor    16, 25
                DisplayString deleteArrow
                moveCursor    x, y
                DisplayString arrow
                jmp           again
endm

ExitProgram MACRO
                mov ah, 4Ch
                int 21h
ENDM

.model small
.stack 100h
.data
    GameName      db 'Brick Breaker Game','$'
    StartGame     db 'Start Game','$'
    StartConv     db 'Start Conversation','$'
    Exit          db 'Exit','$'
    arrow         db 10h,'$'
    deleteArrow   db ' ','$'
    currentOption db 0
.code

main proc far
             mov           ax, @data
             mov           ds, ax

             ClearScreen

             moveCursor    7, 30
             DisplayString GameName
             moveCursor    12, 34
             DisplayString StartGame
             moveCursor    14, 30
             DisplayString StartConv
             moveCursor    16, 37
             DisplayString Exit
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
             DisplayString StartGame
             ExitProgram
    p2:      cmp           currentOption,1
             jnz           p3
             DisplayString StartConv
             ExitProgram
    p3:      DisplayString Exit
             ExitProgram

    dummy1:  jmp           up

    down:    cmp           currentOption, 2
             jnz           downcont
             mov           currentOption, 0
             changeArrow   12, 25

    downcont:inc           currentOption
             cmp           currentOption, 2
             jnz           c1
             changeArrow   16, 25

    c1:      changeArrow   14, 25

    up:      cmp           currentOption, 0
             jnz           upcont
             mov           currentOption, 2
             changeArrow   16, 25

    upcont:  dec           currentOption
             cmp           currentOption, 0
             jnz           c2
             changeArrow   12, 25

    c2:      changeArrow   14, 25

main endp
end main
