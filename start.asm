extrn single:FAR
extrn conv:FAR
extrn game:FAR

initPort MACRO
    ;Set Divisor Latch Access Bit
    MOV DX, 3FBh 				; Line Control Register
    MOV AL, 10000000b			;Set Divisor Latch Access Bit
    OUT DX, AL					;Out it
	
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    MOV DX, 3F8h			
    MOV AL, 0Ch			
    OUT DX, AL

    ;Set MSB byte of the Baud Rate Divisor Latch register.
    MOV DX, 3F9h
    MOV AL, 00h
    OUT DX, AL

    ;Set port configuration
    MOV DX, 3FBh
    MOV AL, 00011011b
    OUT DX, AL
ENDM


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
                moveCursor    10,25
                DisplayString deleteArrow
                moveCursor    12, 25
                DisplayString deleteArrow
                moveCursor    14, 25
                DisplayString deleteArrow
                moveCursor    16, 25
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
    GameName      db 'Brick Breaker Game','$'
    SinglePlayer     db 'Single Player Mode','$'
    TwoPlayers     db 'Two Players Mode','$'
    StartConv     db 'Start Conversation','$'
    Exit          db 'Exit The Game','$'
    arrow         db 10h,'$'
    deleteArrow   db ' ','$'
    currentOption db 0
.code

main proc far
        initPort
        mov ax, @data
        mov ds, ax
        mov ax,3h
        int 10h

        ClearScreen
        moveCursor    6, 30
        DisplayString GameName
        moveCursor    10, 30
        DisplayString SinglePlayer
        moveCursor    12, 31
        DisplayString TwoPlayers
        moveCursor    14, 30
        DisplayString StartConv
        moveCursor    16, 32
        DisplayString Exit
        changeArrow   10, 25

    rec:
        MOV DX, 3FDh		
        in AL, DX			
        AND al, 1	
        JZ again	
        MOV DX, 03F8h
        in al, dx
        cmp al, 's'
        jnz tryc
        call game
        tryc:
        cmp al,'c'
        jnz again
        call conv

    again:               
        mov ah,1
        int 16h
        jz rec
        mov ah, 0               
        int 16h                 
        cmp ah, 50h           
        jz  down                
        cmp ah, 48h          
        jz  dummy1            
        cmp al, 0Dh            
        jz  check              
        jmp again              

    dum:jmp rec

    check:   
             ClearScreen
             cmp           currentOption,0
             jnz           p2
             call single
             ExitProgram
    p2:      cmp           currentOption,1
             jnz           p3
             mov dx,3FDH 			
             in al , dx 				
             AND al , 00100000b
             jz rec 
             mov dx, 3F8H			
             mov al, 's'       	
             out dx, al
             call game
             ExitProgram
    p3:      cmp           currentOption,2
             jnz           p4
             mov dx,3FDH 			
             in al , dx 				
             AND al , 00100000b
             jz dum 
             mov dx, 3F8H
             mov al, 'c'       	
             out dx, al
             call conv
    p4:      ExitProgram

dummy1:jmp up

    down:    cmp           currentOption, 3
             jnz           downcont
             mov           currentOption, 0
             changeArrow   10, 25
    downcont:inc           currentOption
             cmp           currentOption, 1
             jnz           drow2
             changeArrow   12, 25

    drow2:      cmp           currentOption, 2
             jnz           drow3
             changeArrow   14, 25

    drow3:      changeArrow   16, 25

    up:      cmp           currentOption, 0
             jnz           upcont
             mov           currentOption, 3
             changeArrow   16, 25

    upcont:  dec           currentOption
             cmp           currentOption, 0
             jnz           urow1
             changeArrow   10, 25

    urow1:   cmp           currentOption, 1
             jnz           urow2
             changeArrow   12, 25

    urow2:   changeArrow   14, 25

main endp
end main