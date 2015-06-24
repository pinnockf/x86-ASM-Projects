;Franklin Pinnock
;Spring 2013
;CS 14
;Project 6 (Extra Credit)
;===============================================================
;| Project 6 (Extra Credit)                                    |
;===============================================================
;| User inputs a month and a day, and program will output the  |
;| corresonding the day of the year.                           |
;|                                                             |
;| Franklin Pinnock                                            |
;===============================================================
.MODEL  small

.STACK  100h

.DATA
jan         equ  0
feb         equ  jan + 31
mar         equ  feb + 28
apr         equ  mar + 31
may         equ  apr + 30
jun         equ  may + 31
jul         equ  jun + 30
aug         equ  jul + 31
sep         equ  aug + 31
oct         equ  sep + 30
nov         equ  oct + 31
dem         equ  nov + 30

month_arr   db   2 DUP (?)
day_arr     db   2 DUP (?)
year_arr    db   2 DUP (?)
ans_arr     db   3 DUP (?),'$'

month       dw 0
day         dw 0
year        dw 0
ans         dw 0

ENDL        db 10,13,'$'
prompt      db 'Enter month, day, and year (mm/dd/yy): ','$'
prompt_ans  db 'Day = ','$'

Arr_Size    equ  2
Ans_Size    equ  3
Buff_Size   equ  10
;--------------------------------------------
;Trying some new stuff we didnt do in class
;with a keyboard buffer.
;--------------------------------------------
KeyBuff   Label Byte                ;Indicates start of parameter list
  Maxlen    DB Buff_Size            ;Max length is 20 char
  Strlen    DB ?                    ;Actual lengthset by INT 21h
  InBuff    DB Buff_Size DUP(' ')   ;space to store string

.CODE
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

    Display_Prompt:
      mov     ah,     9
      lea     dx,     prompt
      int     21h
    Fill_Buffer:
      mov     ah,     0ah
      lea     dx,     keybuff
      int     21h

    Fill_Month_Array:
      lea     si,     InBuff
      lea     di,     month_arr
      mov     cx,     Buff_Size

    Fill_Loop:
      cmp     byte ptr [si],     13
      je      Convert_Arrays_to_Hex
      cmp     byte ptr [si],     '/'
      je      Skip_Move
      cmp     cx,                Buff_Size-3
      je      Fill_Day_Array
      cmp     cx,                Buff_Size-6
      je      Fill_Year_Array
     Move_Contents:
      mov     al,     byte ptr [si]
      mov     byte ptr [di],    al
     Skip_Move:
      inc     si
      inc     di
      loop    Fill_Loop

      jmp     Convert_Arrays_to_Hex

    Fill_Day_Array:
      lea     di,     day_arr
      jmp     Move_Contents
    Fill_Year_Array:
      lea     di,     year_arr
      jmp     Move_Contents


    Convert_Arrays_To_Hex:
      mov     si,     Arr_Size
      dec     si
      mov     bx,     1
      mov     cx,     10
     Convert_Month:
      cmp     month,      0
      jne     Convert_Day
      mov     di,     0
      jmp     Next_Place_Value
     Convert_Day:
      cmp     day,      0
      jne     Convert_Year
      add     si,     (day_arr-month_arr)


      mov     di,     2
      jmp     Next_Place_Value
     Convert_Year:
      cmp     year,      0
      jne     Process_Data
      add     si,     (year_arr-month_arr)

      mov     di,     4

    Next_Place_Value:
      sub     ax,     ax
      mov     al,     month_arr+[si]
      sub     ax,    '0'
      mul     bx
      add     month+di,   ax
      mov     ax,     bx
      mul     cx
      mov     bx,     ax
      dec     si
      cmp     bx,     100
      jne     Next_Place_Value

      jmp     Convert_Arrays_To_Hex

    Process_Data:
      ;mov     ax,     ans

      cmp     month,  1
      je      is_jan
      cmp     month,  2
      je      is_feb
      cmp     month,  3
      je      is_mar
      cmp     month,  4
      je      is_apr
      cmp     month,  5
      je      is_may
      cmp     month,  6
      je      is_jun
      cmp     month,  7
      je      is_jul
      cmp     month,  8
      je      is_aug
      cmp     month,  9
      je      is_sep
      cmp     month, 10
      je      is_oct
      cmp     month, 11
      je      is_nov
      cmp     month, 12
      je      is_dem
    Select_Month:

    is_jan:
      mov     ax,    jan
      jmp     Add_day
    is_feb:
      mov     ax,    feb
      jmp     Add_day
    is_mar:
      mov     ax,    mar
      jmp     Add_day
    is_apr:
      mov     ax,    apr
      jmp     Add_day
    is_may:
      mov     ax,    may
      jmp     Add_day
    is_jun:
      mov     ax,    jun
      jmp     Add_day
    is_jul:
      mov     ax,    jul
      jmp     Add_day
    is_aug:
      mov     ax,    aug
      jmp     Add_day
    is_sep:
      mov     ax,    sep
      jmp     Add_day
    is_oct:
      mov     ax,    oct
      jmp     Add_day
    is_nov:
      mov     ax,    nov
      jmp     Add_day
    is_dem:
      mov     ax,    dem

    Add_Day:
      add     ax,    day
      mov     ans,   ax

    Show_Answer:
      push    ans
      push    offset ans_arr
      push    ans_size
      CALL    PUTDEC

      CRLF    2
    Display_Prompt_Ans:
      mov     ah,     9
      lea     dx,     prompt_ans
      int     21h
    Display_Answer:
      lea     dx,     ans_arr
      int     21h




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
END Main
