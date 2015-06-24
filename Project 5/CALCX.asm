;===============================================================
; CALCX
;
; Calculates and prints the X line.
;===============================================================
.Model Small

.CODE
Extrn   PUTDEC:near
Extrn   A, B, C, X, XYZ_Size,Prompt_X, sign_flag
Public  CALCX

;---------------------------------------------------------------
; DISPLAYCHR
;
; Accepts a character paramater and displays it.
;---------------------------------------------------------------
  DISPLAYCHR MACRO char
    mov     dl, char
    mov     ah, 02H
    int     21h
  endm

CALCX PROC
    cmp     A,      30
    jg      Greater_Than_30

;--------------------------------------------
;If a <= 30: x = 4a - 11(b+1) + 5c
;--------------------------------------------
  Less_Than_Equal_30:
    mov     ax,     B
    inc     ax                      ;ax: (b+1)
    mov     bx,     11
    mul     bx
    neg     ax                      ;ax: -11(b+1)
    mov     cx,     ax
    mov     ax,     4
    mov     bx,     A
    add     cx,     ax              ;cx: 4a - 11(b+1)
    mov     ax,     5
    mov     bx,     c
    mul     bx                      ;ax: 5c
    add     cx,     ax
    mov     ax,     cx              ;ax: 4a - 11(b+1) + 5c
    jmp     Check_If_Signed

;--------------------------------------------
;If a > 30: x = 7(a+1) - 35b + 8c;
;--------------------------------------------
  Greater_Than_30:

    mov     ax,     A               ;ax: (a)
    inc     ax                      ;ax: (a+1)
    mov     bx,     7
    mul     bx
    mov     cx,     ax              ;cx: 7*(a+1)
    mov     ax,     35
    mov     bx,     B
    mul     bx
    neg     ax
    add     cx,     ax              ;cx: 7(a+1) - 35b
    mov     ax,     8
    mov     bx,     C
    mul     bx                      ;ax: 8c
    add     cx,     ax
    mov     ax,     cx              ;cx: 7(a+1) - 35b + 8c;

  Check_If_Signed:
    push    ax
    mov     bx,     offset X
    push    bx
    mov     cx,    XYZ_SIZE
    push    cx
    call    PUTDEC

;--------------------------------------------
;Print x and remove leading zeros
;--------------------------------------------
  Display_Prompt_X:
    lea     dx,     prompt_x
    mov     ah,     09h
    int     21h

  Is_X_Negative:
    cmp     sign_flag, 0            ;Check if sign flag is set.
    je      Display_X

  Print_Negative_Sign:              ;If it is, then
    DISPLAYCHR   '-'                ;Displax a negative in front of X.
    dec     sign_Flag

  Display_X:
    lea     bx,     X
    mov     si,     0               ;Start decimal array index at 0.
    mov     ax,     0               ;Used to count leading 0's.

  Count_Leading_Zeros_X:
    cmp     byte ptr bx[si], '0'    ;Compare current element of the array
                                    ;with the char '0'.
    jne     No_More_Leading_Zeros_X ;If char is not '0', break loop.
    inc     ax                      ;If it is, then increase ax,
    inc     si                      ;Move to the next element.
    jmp     Count_Leading_Zeros_X

  No_More_Leading_Zeros_X:
    mov     di,     ax              ;Store the number of leading 0's found in di
                                    ;Ax is also the position of the first non-zero
                                    ;number in the array.
  Shift_Elements_X:
    mov     si,     di              ;Set si to current current non-zero number.
    mov     cx,     ax              ;Set loop counter to amount of leading zeros
                                    ;found.
  Shift_Elements_Loop_X:
    cmp     byte ptr bx[di],    '$' ;Check if we have reached the endof the array.
    je      Fix_End_X               ;Jump if we have to Fix_End_X
    mov     dl,     byte ptr bx[si] ;If not, move the current number in the array
    mov     byte ptr bx[si-1],  dl  ;to the left n times, where n = the number of
    dec     si                      ;leading zeros found.
    loop    Shift_Elements_Loop_X
    inc     di                      ;Move to the next number in the array to be
                                    ;shifted.
    jmp     Shift_Elements_X

  Fix_End_X:
    mov     si,     XYZ_Size        ;Size of array.
    dec     si                      ;The end position of the array = size - 1.
    mov     cx,     ax              ;Set loop counter to amount of leading zeros
                                    ;found.

  Fix_End_Loop_X:
    mov     dl,     ' '             ;Replace each char in the array from right to
    mov     byte ptr bx[si],  dl    ;left with a blank, n times. Where n = number of
    dec     si                      ;leading zeros found.
    loop    Fix_End_Loop_X

    lea     dx,     X
    mov     ah,     9
    int     21h
    ret
CALCX ENDP
END
