;===============================================================
;|Project 4                                                    |
;===============================================================
;|This program makes the user input a name and a phone number, |
;|displays the name, and then dsplays the number sorted from   |
;|least to greatest.                                           |
;|                                                             |
;|Franklin Pinnock                                             |
;===============================================================

.XLIST
include proj4mac.asm
.LIST

.MODEL  small

.STACK  100h

.DATA
prompt_msg1   db  'Name? (Press Enter when finished): $'
prompt_msg2   db  'Phone#? (Without dashes/spaces): $'
prompt_msg3   db  'Name: $'
prompt_msg4   db  'Original Phone#: $'
prompt_msg5   db  'Sorted Phone#: $'
ENDL          db  10,13,'$'

names_size    equ 20
names         db  names_size DUP (?)
phones_size   equ 11
phones        db  phones_size DUP (?)
sorted_size   equ 11
sorted        db  sorted_size DUP (?)

names_ptr     dw  offset names
phones_ptr    dw  offset phones
sorted_ptr    dw  offset sorted

.CODE
;===============================================================
;Main
;===============================================================
Main PROC
    mov       ax,@data
    mov       ds,ax

    Put_Str   prompt_msg1
    mov       bx, names_ptr
    mov       cx, names_size
    Call      Fill_Names

    Put_Str   prompt_msg2
    mov       bx, phones_ptr
    mov       cx, phones_size
    call      Fill_Phones

    mov       si, phones_ptr
    mov       di, sorted_ptr
    mov       cx, phones_size
    call      Copy_Array

    mov       bx, sorted_ptr
    mov       cx, sorted_size
    call      Sort_Array

    CRLF      2
    Put_Str   prompt_msg3
    Put_Str   names
    CRLF      1
    Put_Str   prompt_msg4
    Put_Str   phones
    CRLF      1
    Put_Str   prompt_msg5
    Put_Str   sorted

    Dos_Return
Main ENDP

;===============================================================
; Copy_Array
;------------------------------------
; Paramaters:
; si - source array address
; di - destination array address
; cx - length of source array
;===============================================================
Copy_Array PROC
    push_all

    Copy_Array_Loop:
    mov   al,               byte ptr [si]
    mov   byte ptr [di],    al
    inc   si
    inc   di
    loop  Copy_Array_Loop

    pop_all
    ret
Copy_Array ENDP

;===============================================================
; Sort_Array
;---------------------------------------------------------------
; bx - address of array to be sorted
;===============================================================
Sort_Array PROC
    push_all

    Sort:
    mov   si,               0               ;Initialize array[n]
    mov   di,               1               ;Initialize array[n+1]

    Check_End_Of_Array:
    cmp   byte ptr bx[di], '$'              ;Check if we are at the end of the array.
    je    Is_Array_Sorted                  ;If we are at the end, then check if sorted.
    mov   al,               byte ptr bx[si]
    mov   dl,               byte ptr bx[di]
    cmp   al,               dl              ;Compare array{n] and array[n+1]
    jb    Dont_Swap                         ;If array[n] > array[n+1], then
                                             ;swap their positions in the array.
    Swap:
    xchg  al,               dl
    mov   byte ptr bx[si],  al
    mov   byte ptr bx[di],  dl
    Swap_Flag:
    mov   cx,               1               ;Flag used to see whether or not a swap has
                                             ;occured
    Dont_Swap:
    inc   si                                ;Move to the next pair of consecutive numbers
    inc   di                                ;in the array.
    cmp   cx,               1               ;Check if the Swap flag has been set.
    je    Check_End_Of_Array              ;If the swap flag has been set,
    cmp byte ptr bx[di],   '$'              ;and we have not reach the end of the array,
    jne   Check_End_Of_Array              ;then

    Is_Array_Sorted:
    mov   si,               0
    mov   di,               1
    mov   cx,               9

    Is_Array_Sorted_Loop:                  ;Cycle through the array
    mov   al,               byte ptr bx[si]
    mov   dl,               byte ptr bx[di]
    cmp   al,               dl               ;compare the elements
    ja    Sort                               ;If a swap needs to be made, then try to sort.
    inc   si
    inc   di
    loop  Is_Array_Sorted_Loop

    pop_all
    ret
Sort_Array ENDP

;===============================================================
;Fill_Names
;---------------------------------------------------------------
; Paramaters:
; bx - address of source array
; cx - length of source array
;===============================================================
Fill_Names PROC
    push  ax
    push  dx

    mov   ah,               01h   ;Set ah to 1 for use with int 21h (input char).
    mov   si,               0     ;Keep track of position in array.


  Fill_Names_Loop:
    int   21h                     ;Hold input char in al (DOS FUNCTION)
    cmp   al,               13    ;Check for enter key (carriage return).
    je    Append_Dollar
    mov   bx+[si],          al    ;Set element of array to user input char
    inc   bx                       ;Move to next element in array
    loop  Fill_Names_Loop

  Append_Dollar:
    mov   al,               '$'
    mov   bx+[si],          al    ;Append Dollar Sign to the end of array.

    pop   dx
    pop   ax
    ret
Fill_Names ENDP

;===============================================================
;Fill_Phones
;---------------------------------------------------------------
; Paramaters:
; bx - address of source array
; cx - length of source array
;===============================================================
Fill_Phones PROC

    push  ax
    push  dx

    mov   ah,               01h   ;Set ah to 1 for use with int 21h (input char).
    mov   si,               0     ;Keep track of position in array.

    dec   cx                      ;Last element in array will be the $ sign.
  Get_Number_Loop:
    int   21h                     ;Hold input char in al (DOS FUNCTION)
    mov   bx+[si],          al    ;Set element of array to user input char
    inc   si                      ;Move to next postion.
    loop  Get_Number_Loop


  Append_Dollar_Number:
    mov   al,               '$'
    mov   bx+[si],          al    ;Append Dollar Sign to the end of array.

    pop   dx
    pop   ax
    ret
Fill_Phones ENDP

END Main
