;===============================================================
;| PUTDEC
;|
;| -Converts a hexadecimal number number to its decimal
;|  equivalent.
;| -Handles the display of signed numbers.
;|
;| Arg1(inputValue): The hex value to be converted to decimal.
;| Arg2(array):      The address of the first location of the
;|                   array in which computed value will be stored.
;| Arg3(arrSize):    The size of the array.
;===============================================================
.Model SMALL

.CODE
Extrn   sign_flag
Public  PUTDEC

PUTDEC PROC
  ARG   arrSize:word, array:word, inputValue:word = BytesUsed

  ;Allow the paramater's to be addressed.
    push    bp                      ;save stack pointer
    mov     bp,     sp

    mov     ax,     inputValue      ;Store hex value in ax.
    cmp     ax,     0               ;Is the value negative?
    jge Convert_To_Dec              ;If not, then convert to decimal.

  Set_Negative_Flag:
    inc     sign_flag               ;If it is, then set sign flag, and

  Two_Complement:                   ;Perform 2's Complement to diplay
    mov     bx,     0FFFFh          ;proper value.
    sub     bx,     ax
    inc     bx
    mov     ax,     bx

  Convert_to_Dec:
    mov     cx,     [arrSize]
    mov     si,     [arrSize]
    dec     si
  Division_Loop:
    mov     bx,     10
    mov     dx,     0
    div     bx
    add     dl,     '0'
    mov     bx,     array
    mov     bx+[si],dl
    dec     si
    loop    Division_Loop

    pop     bp                      ;Restore BP
    ret     BytesUsed               ;Clean up stack and return.
PUTDEC ENDP
END
