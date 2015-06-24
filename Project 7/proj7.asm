;===============================================================
;| HCP Submission                                              |
;===============================================================
;| This program searches an array of integers, using a binary  |
;| search algorithims and determines how many iterations it    |
;| takes to find the integer in the array.                     |
;|                                                             |
;| Franklin Pinnock                                            |
;===============================================================
.MODEL  small
.STACK  100h

.DATA

array_size   equ 50
array        dw  array_size DUP (?),'$'
array_ptr    dw  offset array

search        dw  0
low_bound     dw  0
high_bound    dw  0
midpoint      dw  0
count         dw  0

count_size    equ 2
count_str     db  count_size DUP (?)

ENDL          db 10,13,'$'
prompt_1      db  'Enter the integer you would like to find: ','$'
prompt_2      db  'Using a linear search algorithm, it takes ','$'
prompt_3      db  'Using a binary search algorithm, it takes ','$'
msg_1         db  'iteration(s to find the number ','$'
msg_2         db  ' in the sorted array.','$'

Buff_Size     equ  3
KeyBuff       Label Byte                ;Indicates start of parameter list
  Maxlen        DB Buff_Size            ;Max length is 20 char
  Strlen        DB ?                    ;Actual lengthset by INT 21h
  InBuff        DB Buff_Size DUP(' ')   ;space to store string

.CODE
;===============================================================
; Macros
;---------------------------------------------------------------
; CRLF
;
; Prints a newline, n number of times
;---------------------------------------------------------------
  CRLF MACRO  n
  LOCAL Put_String_Loop
      mov     dx,     OFFSET ENDL
      mov     ah,     9

      mov     cx,     n
    Put_String_Loop:
      int     21h
      loop    Put_String_Loop
  endm
;===============================================================
; Main
;===============================================================
  Main PROC
      mov     ax,     @data
      mov     ds,     ax

  ;--------------------------------------------
  ;Fill array with consecutive integer values.
  ;--------------------------------------------
      call    FillArray
  ;--------------------------------------------
  ;Set the initial left and right bounds of the
  ;for the binary search, then calculate
  ;midpoint based off these values.
  ;--------------------------------------------
    Set_Initial_Bounds:
      add     low_bound,  0
      add     high_bound, array_size-1
      call    SetMidpoint
    Display_Prompt:
      lea     dx,     prompt_1
      mov     ah,     09h
      int     21h
  ;------------------------------------------------
  ;Obtain search value(s.v.) from user.
  ;------------------------------------------------
    Fill_Buffer:
      mov     ah,     0ah
      lea     dx,     keybuff
      int     21h
    Append_Dollar:
      mov     si,     Buff_Size-1
      mov     byte ptr InBuff[si], '$'
    Convert_Buffer_To_Hex:
      mov     si,     Buff_Size-2
      mov     bx,     1
      mov     cx,     10
    Next_Place_Value:
      mov     ax,     0
      mov     al,     byte ptr InBuff+[si]
      sub     ax,    '0'
      mul     bx
      add     search, ax
      mov     ax,     bx
      mul     cx
      mov     bx,     ax
      dec     si
      cmp     bx,     100
      jne     Next_Place_Value
    ;------------------------------------------------
    ;Compare it with the value indexed by the midpoint
    ;(midpt).
    ;
    ;- If (s.v. == midpt), then s.v. has been found.
    ;- If (s.v. < midpt), then high_bound = midpt - 1.
    ;- If (s.v. > midpt), then low_bound = midpt + 1
    ;------------------------------------------------
    Compare_Value:
      inc     count
      mov     ax,     [search]
      mov     si,     [midpoint]
      shl     si,     1
      mov     bx,     [array+si]
      cmp     ax,     bx
      jg      Update_Low_Bound
      jl      Update_High_Bound
      je      Value_Found
    Update_Low_Bound:
      mov     bx, [midpoint]
      add     bx, 1
      mov     low_bound, bx
      call    SetMidpoint
      jmp     Compare_Value
    Update_High_Bound:
      mov     bx, [midpoint]
      sub     bx, 1
      mov     high_bound, bx
      call    SetMidpoint
      jmp     Compare_Value

    Value_Found:
      CRLF    2
      lea     dx,     prompt_3
      mov     ah,     09h
      int     21h

    ;------------------------------------------------
    ;Display Results
    ;------------------------------------------------
      push    count
      push    offset count_str
      push    count_size
      call    PUTDEC

      lea     dx,     count_str
      mov     ah,     09h
      int     21h

      lea     dx,     msg_1
      int     21h
      lea     dx,     InBuff
      int     21h
      lea     dx,     msg_2
      int     21h

      mov     ah,     4ch             ;DOS: terminate program
      mov     al,     0               ;return code will be 0
      int     21h                     ;terminate the program

  Main ENDP
;===============================================================
;| FillArray
;|
;| The address of the first location of the  array, that will
;| be filled with integers, is passed by value to bx.
;===============================================================
  FillArray PROC

      mov     ax,     1
      mov     si,     0
      mov     bx,     array

    Fill_Loop:
      mov     word ptr bx[si], ax
      cmp     word ptr bx[si+2], '$'
      je      Finished
      inc     ax
      add     si,     2
      jmp     Fill_Loop

    Finished:
      ret
  FillArray ENDP
;===============================================================
;| SetMid
;|
;| -Calculates the midpoint based on the values of high_bound and
;|  low bound.
;|
;| Arg1(high_bound): Pass by reference to ax.
;| Arg2(low_bound):  Pass by reference to bx.
;|
;===============================================================
  SetMidpoint PROC

      mov     ax, high_bound
      mov     bx, low_bound
      add     ax, bx
      shr     ax, 1
      mov     midpoint, ax
      ret

  SetMidpoint ENDP
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
    ARG   arrSize:word, array_offset:word, inputValue:word = @@BytesUsed

    ;Allow the paramater's to be addressed.
      push    bp                      ;save stack pointer
      mov     bp,     sp

      mov     ax,     inputValue      ;Store hex value in ax.

    Convert_to_Dec:
      mov     cx,     arrSize
      mov     si,     cx
      dec     si
    Division_Loop:
      mov     bx,     10
      mov     dx,     0
      div     bx
      add     dl,     '0'
      mov     bx,     array_offset
      mov     bx+[si],dl
      dec     si
      loop    Division_Loop

      pop     bp                      ;Restore BP
      ret     @@BytesUsed               ;Clean up stack and return.
  PUTDEC ENDP
END Main
