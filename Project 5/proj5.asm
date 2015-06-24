;This is my 5th project for CS14
;My name is Franklin Pinnock
;My phone# is 515-9512
;===============================================================
;|Project 5                                                    |
;===============================================================
;|This program makes the user input a phone number, then stores|
;|the first two digits it in A, the next two digits in B, and  |
;|the next two digits in C. Then computes and displays X, Y,   |
;|and Z based off of predetermined formulas.                   |
;|                                                             |
;|x = 4a - 11(b+1) + 5c                                        |
;|y = 56*a / (2*b + 3*c)                                       |
;|z = -41a % (6b - 4c)                                         |
;|                                                             |
;|Franklin Pinnock                                             |
;===============================================================
jumps

.XLIST
include proj5mac.asm
.LIST

.MODEL  small

.STACK  100h

.DATA
INITDATA

.CODE
;===============================================================
; Main
;===============================================================
  Main PROC
      mov     ax,@data
      mov     ds,ax

  ;--------------------------------------------
  ;Diplay prompt and store phone number into an
  ;array of bytes.
  ;--------------------------------------------
      lea     dx,     prompt_ph       ;Dispay Phone Prompt
      mov     ah,     09h
      int     21h

      mov     si,     0               ;Phone array index.
      mov     bx,     phone_ptr
      mov     cx,     phone_size
      dec     cx                      ;Phone array ends at i-1

    Fill_Phone_Loop:
      mov     ah,     01h             ;DOS:Set ah to 1 for use with int 21h.
      int     21h                     ;----Store input char in al.
      mov     bx+[si],al              ;Store input char into current element of
                                      ;array
      inc     si                      ;Move to next element in array
      cmp     si,     3               ;Display a dash between the 3rd and 4th
                                      ;number.
      jne     Not_Dash
      DISPLAYCHR '-'
     Not_Dash:
      loop    Fill_Phone_Loop         ;Loop until array is filled with 7 numbers

  ;--------------------------------------------
  ;Copy contents of phone array into three
  ;different arrays
  ;
  ;A_str[0,1]=phone[0,1]
  ;B_str[0,1]=phone[2,3]
  ;C_str[0,1]=phone[4,5]
  ;--------------------------------------------
    Fill_A:
      mov     si,     phone_ptr       ;Store 1st position of phone array in si.
      mov     di,     offset A_str    ;Store 1st position of A_Str array.
      mov     cx,     6               ;Loop counter: Move 6 numbers.

    Fill_Loop:
      cmp     cx,     4               ;If 2 numbers have been moved,
      je      Fill_B                  ;jump to Fill_B
      cmp     cx,     2               ;If 2 more numbers haev been moved,
      je      Fill_C                  ;jump to Fill_C
     Move_Contents:
      mov     al,     byte ptr [si]
      mov     byte ptr [di],    al
      inc     si                      ;Move to next position in phone array.
      inc     di                      ;Move to next position in current array.
      loop    Fill_Loop

      jmp     Convert_ABC_To_Hex

    Fill_B:
      mov     di,     offset B_str    ;Store 1st position of B_str array into di.
      jmp     Move_Contents
    Fill_C:
      mov     di,     offset C_str    ;Store 1st position of C_str array into di.
      jmp     Move_Contents

  ;--------------------------------------------
  ;Convert the decimal representations of the
  ;A, B, and C into hexadecimal so they can be
  ;used to obtain the values of X, Y, and Z.
  ;
  ;A_str(dec)->A(hex)
  ;B_str(dec)->B(hex)
  ;C_str(dec)->C(hex)
  ;--------------------------------------------
    Convert_ABC_To_Hex:
      mov     si,     ABC_Size        ;A/B/C_Str arrays only have a 1 and 10s place
      dec     si                      ;Arrays end at (n-1) element
      mov     bx,     1               ;Holds current place value being converted.
      mov     cx,     10
     Convert_A:
      cmp     A,      0               ;Has A been converted yet?
      jne     Convert_B               ;If it has then convert B.
      mov     di,     0               ;di controls displacement from variable A.
      jmp     Next_Place_Value
     Convert_B:
      cmp     B,      0               ;Has B been converted yet?
      jne     Convert_C               ;If it has then convert C.
      add     si,     (B_Str-A_Str)   ;Store the displacement between B_str and
                                      ;A_str (will point to B_Str[0]).
      mov     di,     2               ;The address of B is two bytes down from A.
      jmp     Next_Place_Value
     Convert_C:
      cmp     C,      0               ;Has C been converted yet?
      jne     Display_ABC             ;If it has, jump to Display_ABC.
      add     si,     (C_Str-A_Str)   ;Store the displacement between C_str and
                                      ;B_str (will point to C_str[0]).
      mov     di,     4               ;The address of C is 4 bytes down from from A.

    Next_Place_Value:
      sub     ax,     ax              ;Clear ax
      mov     al,     A_str+[si]
      sub     ax,    '0'
      mul     bx
      add     A+di,   ax
      mov     ax,     bx
      mul     cx
      mov     bx,     ax
      dec     si
      cmp     bx,     100              ;Break loop after 10's place is converted.
      jne     Next_Place_Value

      jmp     Convert_ABC_to_Hex      ;Jump if loop is broken, and A, B, and C are
                                      ;converted

  ;--------------------------------------------
  ;Display A, B, C, X, Y, and Z
  ;--------------------------------------------
    Display_ABC:
      push    A
      push    offset A_STR
      push    ABC_SIZE
      CALL    PUTDEC
      CRLF    2
    Display_Prompt_A:
      mov     ah,     9
      lea     dx,     prompt_a
      int     21h
    Display_A:
      lea     dx,     A_Str
      int     21h
      CRLF    2

      push    B
      push    offset  B_STR
      push    ABC_SIZE
      CALL    PUTDEC
    Display_Prompt_B:
      mov     ah,     9
      lea     dx,     prompt_b
      int     21h
    Display_B:
      lea     dx,     B_Str
      int     21h
      CRLF    2

      push    C
      push    offset  C_STR
      push    ABC_SIZE
      CALL    PUTDEC
    Display_Prompt_C:
      mov     ah,     9
      lea     dx,     prompt_c
      int     21h
    Display_C:
      lea     dx,     C_Str
      int     21h
      CRLF    2

      Call    CALCX
      CRLF    2

      CALCY
      CRLF    2

      CALCZ
      CRLF    2

      Dos_Return

      mov     ah,     4ch             ;DOS: terminate program
      mov     al,     0               ;return code will be 0
      int     21h                     ;terminate the program
  Main ENDP
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
      mov     ax,     0FFFFh          ;proper value.
      sub     ax,     cx
      inc     ax

    Convert_to_Dec:
      mov     cx,     arrSize
      mov     si,     cx
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
;===============================================================
; CALCX
;
; Calculates and prints the X line.
;===============================================================
  CALCX PROC
      cmp     A,      30
      jg      Greater_Than_30

  ;--------------------------------------------
  ;calculate x
  ;
  ;x = 4a - 11(b+1) + 5c
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

    Greater_Than_30:
    ;x = 7(a+1) - 35b + 8c;
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
      push    offset X
      push    XYZ_SIZE
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
END Main
