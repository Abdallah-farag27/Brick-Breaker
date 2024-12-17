; .model small
; .stack 100h
; .data
;     menuOptions db 'Start Game', '$'
;                 db 'Options    ', '$'
;                 db 'Exit       ', '$'

;     chooselabel db '>','$'
;     startGameMsg db 'Starting the Game...$'   ; Message for Start Game
;     optionsMsg db 'Options Menu...$'          ; Message for Options

;     totalOptions db 3   ; Total number of options
;     currentOption db 0  ; Currently selected option (0-indexed)
;     arrowUp db 72       ; Arrow Up key code
;     arrowDown db 80     ; Arrow Down key code
;     enterKey db 13      ; Enter key code

; .code
; main proc
;     mov ax, @data
;     mov ds, ax

;     ; Set video mode to text mode
;     mov ah, 00h
;     mov al, 03h
;     int 10h

;     ; Main menu display loop
; menu_loop:
;     call displayMenu    ; Show menu options
;     call getKey         ; Get user input
;     cmp ah, arrowUp     ; Check if Arrow Up
;     je moveUp
;     cmp ah, arrowDown   ; Check if Arrow Down
;     je moveDown
;     cmp al, enterKey    ; Check if Enter key
;     je executeOption
;     jmp menu_loop       ; Repeat

; moveUp:
;     cmp currentOption, 0
;     je menu_loop        ; If already at the top, do nothing
;     dec currentOption   ; Move up in the menu
;     jmp menu_loop

; moveDown:
;     cmp currentOption, 2
;     je menu_loop        ; If already at the bottom, do nothing
;     inc currentOption   ; Move down in the menu
;     jmp menu_loop

; executeOption:
;     ; Based on the selected option, perform actions
;     mov al, currentOption  ; No need to zero-extend, it's already a byte
;     cmp al, 0
;     je startGame        ; If "Start Game" selected
;     cmp al, 1
;     je showOptions      ; If "Options" selected
;     cmp al, 2
;     je exitProgram      ; If "Exit" selected
;     jmp menu_loop

; startGame:
;     ; Add your game start logic here
;     mov ah, 09h
;     lea dx, startGameMsg
;     int 21h
;     jmp endProgram

; showOptions:
;     ; Add your options logic here
;     mov ah, 09h
;     lea dx, optionsMsg
;     int 21h
;     jmp menu_loop

; exitProgram:
;     jmp endProgram

; ; Subroutine to display menu options
; displayMenu proc
;     mov ah, 02h         ; Set cursor position function
;     mov dh, 5           ; Row position
;     mov bh, 0           ; Page number
;     mov dl, 10          ; Column position
;     lea si, menuOptions
;     mov cx, 0           ; Option index

; display_loop:
;     ; Set cursor position
;     int 10h

;     ; Print the current option
;     mov ah, 09h
;     lea dx, [si]
;     int 21h

;     ; Highlight the currently selected option
;     mov al, currentOption
;     cmp cl, al
;     jne normalText
;     call highlightText

; normalText:
;     add si, 12          ; Move to the next menu string
;     inc cx
;     cmp cl, totalOptions
;     jne display_loop

;     ret
; displayMenu endp

; ; Subroutine to get a key press
; getKey proc
;     mov ah, 00h
;     int 16h
;     ret
; getKey endp

; ; Subroutine to highlight text (simplified for example)
; highlightText proc
;     ; Highlight text, change text color (example)
;     ret
; highlightText endp

; endProgram:
;     ; Exit to DOS
;     mov ah, 4Ch
;     int 21h

; main endp
; end main

