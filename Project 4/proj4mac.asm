.SALL
;===============================================================
; proj4mac.asm
;
; This file contains all of the macros used by proj4.asm.
;---------------------------------------------------------------
; Push_All
;
; Pushes all of the registers (ax-dx) onto the stack.
;---------------------------------------------------------------
  push_all MACRO
    push    ax
    push    bx
    push    cx
    push    dx
  endm
;---------------------------------------------------------------
; Pop_All
;
; Restores all of the registers (ax-dx) from the stack that were
; pushed by the save macro in reverse order.
;---------------------------------------------------------------
  pop_all MACRO
    pop     dx
    pop     cx
    pop     bx
    pop     ax
  endm
;---------------------------------------------------------------
; DOS_Return (End Program)
;---------------------------------------------------------------
  DOS_Return MACRO
    mov   ah, 4ch                  ;DOS: terminate program
    mov   al, 0                    ;return code will be 0
    int   21h                      ;terminate the program
  endm
;---------------------------------------------------------------
; CRLF
;
; Prints a newline, n number of times
;---------------------------------------------------------------
  CRLF MACRO  n
  LOCAL Put_String_Loop
    push  ax
    push  dx

    mov   dx, OFFSET ENDL

    mov   cx, n
    mov   ah, 9
  Put_String_Loop:
    int   21h
    loop  Put_String_Loop

    push  dx
    push  ax
  endm
;---------------------------------------------------------------
; Put_Str
;
; Accepts a string paramater and displays it to the screen.
;---------------------------------------------------------------
  Put_Str MACRO string
  LOCAL Put_String_Loop
    push  ax
    push  dx

    mov   dx, OFFSET string
    mov   ah, 9
    int   21h

    push  dx
    push  ax
  endm
