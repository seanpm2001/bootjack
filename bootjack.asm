; A minimal boot sector Blackjack.

%ifdef com_file
      org 0x0100                  ; BIOS entry (COM)
%else
      org 0x7C00                  ; BIOS entry (IMG)
%endif
      cpu 8086                    ;
      bits 16                     ;
                                  ; ***** constants *****
deck_size:  equ 52                ; max cards in deck
hand_size:  equ 6                 ; max cards allowed in hand

start:                            ; ***** program entry *****
      cli                         ; disable interrupts
      
      mov si, msg                 ; pointer to message
      call tty_print              ; print message to terminal

      xor bx, bx                  ; i = 0
_init_deck:
      mov [deck + bx], bl         ; pointer to deck
      inc bx                      ; i++
      cmp bx, deck_size           ; check loop condition
      jb _init_deck               ; while (i < deck_size)
      ; TODO: memory filled in GDB

      ; TODO: init random seed
      mov ah, 0                   ; time resolution
      int 0x1A                    ; BIOS interrupt - system time
      mov [seed], dx              ; low order word of tick count
      ; TODO: verify in GDB

      ; TODO: reset subroutine
      ;   - reset player + dealer hands, scores, and indices
      
      ; TODO: shuffle deck subroutine ... also figure out randoms
      
      ; TODO: deal subroutine

      ; TODO: deal initial hand

      ; TODO: eval hand subroutine
      ; TODO: eval dealer hand

      ; TODO: display hand subroutine
      ; TODO: display dealer hand

      ; TODO: eval player hand
      ; TODO: display player hand

      ; TODO: player turn
      ; while (player < 21)
      ;   prompt user, do hit, stand, or quit
      
      ; TODO: check player bust
      
      ; TODO: dealer turn
      ; while (dealer < 17)
      ;   dealer hit
      ;   eval score
      ;   print hand

      ; TODO: check who won

      ; TODO: prompt for next game


end:                              ; ***** end of program *****
      jmp $                       ; repeat current line
      hlt                         ; end program

tty_print:                        ; ***** print string to terminal *****
                                  ; si - pointer to string
                                  ;
      push ax                     ;
      push bx                     ;
      mov ah, 0x0E                ; teletype output function
      mov bx, 0x000F              ; page zero and BL color (graphic mode)
_bp_msg_loop:                     ;
      lodsb                       ; load byte into AL from string (SI)
      cmp al, 0                   ; check for string null terminator
      je _bp_msg_done             ; if end of string, leave
      int 0x10                    ; BIOS interrupt - display one char
      jmp _bp_msg_loop            ; loop
_bp_msg_done:                     ;
      pop bx                      ;
      pop ax                      ;
      ret                         ; end tty_print subroutine

read_kbd:                         ; ***** read char from keyboard *****
      mov ah, 0x00                ; keyboard read function
      int 0x16                    ; BIOS interrupt - read keyboard
      ret                         ; end read_kbd subroutine

                                  ; ***** variables *****
msg:     db "Bootjack", 10, 13, 0 ;
deck:    times deck_size db 0     ; deck of cards
seed:    db 0                     ; random seed

p_hand:  times hand_size db 0     ; player hand
p_idx:   db 0                     ; player index
p_score: db 0                     ; player score

d_hand:  times hand_size db 0     ; dealer hand
d_idx:   db 0                     ; dealer index
d_score: db 0                     ; dealer score

wins:    db 0                     ; player wins
losses:  db 0                     ; player losses

%ifdef com_file
%else
                                 ; ***** complete boot sector *****
      times 510 - ($ - $$) db 0  ; pad rest of boot sector
      db 0x55, 0xAA              ; magic numbers; BIOS bootable
%endif
