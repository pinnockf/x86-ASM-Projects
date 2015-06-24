.SALL
;===============================================================
; proj3mac.inc
;
; This file contains all of the macros used by proj3.asm.
;---------------------------------------------------------------
; Save
;
; Pushes all of the registers (ax-dx) onto the stack.
;---------------------------------------------------------------
  save MACRO
    push    ax
    push    bx
    push    cx
    push    dx
  endm
;---------------------------------------------------------------
; Restore
;
; Restores all of the registers (ax-dx) from the stack that were
; pushed by the save macro in reverse order.
;---------------------------------------------------------------
  restore MACRO
    pop     dx
    pop     cx
    pop     bx
    pop     ax
  endm
;---------------------------------------------------------------
; DOS_Return (End Program)
;---------------------------------------------------------------
  DOS_Return MACRO
    mov     ah, 4ch                  ;DOS: terminate program
    mov     al, 0                    ;return code will be 0
    int     21h                      ;terminate the program
  endm
;---------------------------------------------------------------
; Cout String
;
; Accepts a string paramater and displays it.
;---------------------------------------------------------------
  cout MACRO string
    push    ax
    push    dx

    mov     dx, OFFSET string
    mov     ah, 9
    int     21h

    push    dx
    push    ax
  endm
;---------------------------------------------------------------
; Cout Char
;
; Accepts a character paramater and displays it.
;---------------------------------------------------------------
  coutCh MACRO char
    save
    mov     dl, char
    mov     ah, 02H
    int     21h
    restore
  endm
;---------------------------------------------------------------
; GetNum
;
; Accepts a consecutive number of bytes as a parameter, and
; stores the input into each byte from right to left, if all
; bytes are not filled, then pad with zeros from left to right.
;---------------------------------------------------------------
  getnum MACRO var
  LOCAL Get_Number, Store_Digit, Store_Digit_Loop, Pad_With_Zeros, Done
    save
    mov     ah,       01h ;Set ah to 1 for use with int 21h.
    mov     bx,       0   ;Used to keep track of how many chars have been accepted so far.
    mov     cx,       5
  Get_Number:
    int     21h           ;accept a char
    cmp     al,       '0' ;Check whether or not
    jb      Store_Digit        ;char is a digit between
    cmp     al,       '9' ;0-9, inclusive.
    ja      Store_Digit
    push    ax            ;If it is then push char onto stack.
    inc     bx
    loop    Get_Number

  Store_Digit:
    mov     si,       5
    mov     cx,       bx  ;Set cx equal to the number of digits read in.
  Store_Digit_Loop:
    dec     si            ;Start at last position of 5 digit number.
    pop     ax            ;Pop the digits from the stack into the array
    mov     var+[si], al  ;in reverse order, from right to left..
    loop    Store_Digit_Loop

    cmp     si,       0   ;Check if we have reached the end of the array.
    je      done          ;If so, then we are done.

    mov     si,       0   ;If not, then move to the left-most element of the array.
    mov     cx,       5
    sub     cx,       bx  ;Check how many places of the 5 element array have no value.
  Pad_With_Zeros:
    mov     al,       '0' ;Move the character of 0 into the positions of the array
    mov     var+[si], al  ;that have not been filled by user input,from left to right.
    inc     si
    loop    Pad_With_Zeros
  Done:
    restore
  endm
;---------------------------------------------------------------
; PrintNum
;
; Prints 5 consecutive string of bytes.
;---------------------------------------------------------------
  printnum MACRO var
  LOCAL Print_Character
    save
    mov     si, 0
    mov     cx, 5
  Print_Character:
    coutCH  var+[si]
    inc     si
    loop    Print_Character
    restore
  endm
;---------------------------------------------------------------
; AddHex
;
; Adds two hex numbers, and stores the result.
;---------------------------------------------------------------
addhex MACRO var1,var2,result
    save
    mov     ax,     var1
    mov     bx,     var2
    add     ax,     bx
    mov     result, ax
    restore
endm

;---------------------------------------------------------------
; SubHex
;
; Subtracts two hex numbers together, and stores the result.
;---------------------------------------------------------------
subhex MACRO var1,var2,result
    save

    mov     ax,     var1
    mov     bx,     var2
    cmp     bx,     ax        ;Check if num2 is greater than num1.
    ja      If_Second_Greater
    jmp     subtract

If_Second_Greater:
    xchg    ax,     bx        ;If it is, do (num2-num1)

Subtract:
    sub     ax,     bx        ;If its not, then do (num1-num2)
    mov     result, ax

    restore
endm

;---------------------------------------------------------------
; ResultLine
;
; Displays a leading character followed, by a series of
; characters.
;---------------------------------------------------------------
  resultline MACRO char, var
    save

    coutCh char
    printNum var
    cout endl

    restore
  endm

;---------------------------------------------------------------
; NoLeadingZeros
;
; Removes leading zeros from a number.
;---------------------------------------------------------------
  noleadingzeros MACRO var
  LOCAL  Erase_Leading_Zero, All_Zeros, No_More_Leading_Zeros
    save

    mov     si,        0          ;Start index at left most element of array.
    mov     cx,        0          ;Used to keep track of how many zeros have been erased.

  Erase_Leading_Zero:
    cmp     var+[si], '0'        ;Check if the first element in the number array is '0'.
    jne     No_More_Leading_Zeros ;If it is not, then there are no leading zeros.
    mov     al,        ' '        ;If it is, then replace it
    mov     var+[si], al         ;with a blank space.
    inc     si                    ;Move to the next element to the right.
    inc     cx                    ;Increase counter.
    cmp     cx,        5          ;Have 5 zeros been erased?
    je      All_Zeros             ;If so then, jump.
    jmp     Erase_Leading_Zero

  All_Zeros:
    mov     si,        4          ;If 5 zeros have been replaced, then place a '0', into
    mov     al,        '0'        ;the last position of the array as to not have a blank line.
    mov     var+[si], al
  No_More_Leading_Zeros:

    restore
  endm
;---------------------------------------------------------------
; ShowResult
;
; Displays the results of the addition and subtraction.
;--------------------------------------------------------------
  showresult MACRO
  LOCAL Switch_Lines, Finish_Display

  ;Strip Leading Zeros from all numbers.
    NoLeadingZeros num1
    NoLeadingZeros num2
    NoLeadingZeros addition
    NoLeadingZeros subtraction

  ;Display addend, augend, bar and sum.
    resultLine ' ',num1
    resultLine '+',num2
    resultLine '-',bar
    resultLine ' ',addition
    cout endl

  ;Display minuend, subtrahend, bar and difference.
    mov     ax,num1h
    mov     bx,num2h
    cmp     bx,ax               ;Check if num2 is greater than num1.
    ja      Switch_Lines
    resultLine ' ',num1         ;If num1 is greater than num2, then place num1 on top.
    resultLine '-',num2
    jmp     Finish_Display

  Switch_Lines:
    resultLine  ' ',num2        ;If num2 is greater than num1, then place num2 on top.
    resultLine  '-',num1

  Finish_Display:
    resultLine '-',bar
    resultLine ' ',subtraction
  endm
