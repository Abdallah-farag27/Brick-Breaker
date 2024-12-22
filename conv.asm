public conv

.MODEL SMALL
.STACK 64
.DATA

    value        db ?                                                                                      ; To store the key pressed
    yposS        db 0                                                                                      ; Send screen Y position
    xposS        db 0                                                                                      ; Send screen X position
    xposR        db 0                                                                                      ; Receive screen X position
    yposR        db 13                                                                                     ; Receive screen Y position (lower half)
    separateLine db '________________________________________________________________________________$'
    backspace    db 08h                                                                                    ; Backspace key value

.CODE

    ; Scroll macros for separating send/receive screens
scrollUpper MACRO
                                 mov         ax, 0601h
                                 mov         bh, 0Ah
                                 mov         ch, 0
                                 mov         cl, 0
                                 mov         dh, 11
                                 mov         dl, 79
                                 int         10h
ENDM

scrollLower MACRO
                                 mov         ax, 0601h
                                 mov         bh, 0Ch
                                 mov         ch, 13
                                 mov         cl, 0
                                 mov         dh, 24
                                 mov         dl, 79
                                 int         10h
ENDM

    ; Save cursor position (send)
saveCursorS MACRO
                                 mov         ah, 3h
                                 mov         bh, 0h
                                 int         10h
                                 mov         xposS, dl
                                 mov         yposS, dh
ENDM

    ; Save cursor position (receive)
saveCursorR MACRO
                                 mov         ah, 3h
                                 mov         bh, 0h
                                 int         10h
                                 mov         xposR, dl
                                 mov         yposR, dh
ENDM

    ; Set cursor position
setCursor MACRO x, y
                               mov         ah, 2
                               mov         bh, 0
                               mov         dl, x
                               mov         dh, y
                               int         10h
ENDM

    ; conv program starts here
conv proc far
    

    ; Set video mode to 80x25 text mode
                     mov         ah, 0
                     mov         al, 03h
                     int         10h

    ; Clear screen and display instructions
                     mov         ah, 6
                     mov         al, 0
                     mov         bh, 0Ah
                     mov         ch, 0
                     mov         cl, 0
                     mov         dh, 11
                     mov         dl, 79
                     int         10h

    ; Print a separator line in the middle (row 12)
                     mov         ah, 2               ; Set cursor position
                     mov         bh, 0               ; Page 0
                     mov         dh, 12              ; Row 12 (middle of the screen)
                     mov         dl, 0               ; Column 0
                     int         10h

                     lea         dx, separateLine    ; Load address of the separator line
                     mov         ah, 09h             ; Print string
                     int         21h

                     mov         ah, 6
                     mov         al, 0
                     mov         bh, 0Ch
                     mov         ch, 13
                     mov         cl, 0
                     mov         dh, 24
                     mov         dl, 79
                     int         10h

    ; Set initial positions
                     mov         xposS, 0
                     mov         yposS, 0
                     mov         xposR, 0
                     mov         yposR, 13

    ; Start program loop
                     call        start
                     jmp         exit

start proc
    progloop:        
                     mov         ah, 1               ; Check if a key is pressed
                     int         16h
                     jnz         send
                     jmp         recieve

    send:            
                     mov         ah, 0               ; Clear the keyboard buffer
                     int         16h
                     mov         value, al           ; Save the key in 'value'
    
                     cmp         al, 0Dh             ; If it's the ENTER key
                     jnz         checkBackspace
                     jz          newline

    checkBackspace:  
                     cmp         al, backspace       ; If it's the backspace key
                     jz          handleBackspace

    ; Otherwise, continue with normal processing
                     jmp         cont

    handleBackspace: 
                     cmp         xposS, 0            ; If at the start of the line, do nothing
                     jz          progloop            ; Return to the loop if no character to delete

    ; Move cursor back one position and clear the character
                     dec         xposS
                     setCursor   xposS, yposS
                     mov         dl, ' '             ; Print a space to erase the character
                     mov         ah, 2
                     int         21h

    ; Send backspace control code to the receive section
                     mov         dx, 3FDh
    TX_BACKSPACE:    
                     in          al, dx
                     test        al, 00100000b       ; Check if transmitter is ready
                     jz          TX_BACKSPACE
                     mov         dx, 3F8h
                     mov         al, backspace       ; Send 08h (backspace)
                     out         dx, al
                     jmp         progloop


    newline:         
                     cmp         yposS, 11           ; Check if at the top of the screen
                     jz          XS
                     jnz         YS

    XS:              
                     scrollUpper
                     mov         xposS, 0
                     jmp         cont

    YS:              
                     inc         yposS
                     mov         xposS, 0

    cont:            
                     setCursor   xposS, yposS        ; Set cursor position
                     cmp         xposS, 79           ; If at the right edge
                     jz          checkY
                     jnz         print

    checkY:          
                     cmp         yposS, 11
                     jnz         print
                     scrollUpper
                     mov         xposS, 0
                     setCursor   xposS, yposS

    print:           
                     mov         ah, 2               ; Print the character
                     mov         dl, value
                     int         21h
    
    ; Transmit the data
                     mov         dx, 3FDh
    AGAIN:           
                     in          al, dx
                     test        al, 00100000b
                     jz          recieve
                     mov         dx, 3F8h
                     mov         al, value
                     out         dx, al
                     cmp         al, 27
                     jz          dummy
                     saveCursorS
                     jmp         progloop

    dummy:           
                     jmp         exit

    dummy3:          
                     jmp         send

    recieve:         
                     mov         ah, 1               ; Check if a key is pressed
                     int         16h
                     jnz         dummy3

                     mov         dx, 3FDh
                     in          al, dx
                     test        al, 1
                     jz          recieve

                     mov         dx, 03F8h
                     in          al, dx
                     mov         value, al

                     cmp         value, 27           ; Check if ESC key (27) is pressed
                     jz          dummy

                     cmp         value, 08h          ; Check if Backspace (08h) is received
                     jz          handleBackspaceR

                     cmp         value, 0Dh          ; Check if ENTER (0Dh) is received
                     jz          newlineR

                     jmp         contR               ; Continue to normal processing

    handleBackspaceR:
                     cmp         xposR, 0            ; If at the start of the line, do nothing
                     jz          recieve
                     dec         xposR               ; Move cursor back one position
                     setCursor   xposR, yposR
                     mov         dl, ' '             ; Print a space to erase the character
                     mov         ah, 2
                     int         21h
                     jmp         recieve


    newlineR:        
                     cmp         yposR, 24
                     jz          XR
                     jnz         YR

    XR:              
                     scrollLower
                     mov         xposR, 0
                     setCursor   xposR, yposR
                     jmp         printR

    YR:              
                     inc         yposR
                     mov         xposR, 0

    contR:           
                     setCursor   xposR, yposR
                     cmp         xposR, 79
                     jz          checkYR
                     jnz         printR

    checkYR:         
                     cmp         yposR, 24
                     jnz         printR
                     scrollLower
                     mov         xposR, 0
                     setCursor   xposR, yposR

    printR:          
                     mov         ah, 2
                     mov         dl, value
                     int         21h

                     saveCursorR
                     jmp         progloop

start endp

    exit:            
                    ret
conv endp

end
