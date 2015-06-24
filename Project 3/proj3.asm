;This is my 3rd project for CS 14
;My name is Franklin Pinnock
;===============================================================
; Project 3
;===============================================================
; This program:
; 1)Reads in 2 decimal numbers, that are within the
;   range 0-65535, and 1-5 digits in length.
; 2)Convert each number into hex using a subprogram.
; 3)Get the sum and difference of the 2 numbers (using macros).
; 4)Convert the numbers back to decimal using a subprogram.
; 5)Displays the results.
;
; Franklin Pinnock
; 04/22/13
;===============================================================
.XLIST
include proj3mac.inc
.LIST

.MODEL  small

.STACK  100h

.DATA
prompt1       db 'Enter 1st number. ',10,13,'$'
prompt2       db 'Enter 2nd number. ',10,13,'$'
endl          db 10,13,'$'
bar           db 5 DUP ('-'),'$'
num1          db 5 DUP (?),'$'
num2          db 5 DUP (?),'$'
additionh     dw 0
subtractionh  dw 0

.CODE
EXTRN   Dec2Hex:near, Hex2Dec:near
EXTRN   num1h:word, num2h:word
EXTRN   addition:byte, subtraction:byte
PUBLIC  num1, num2, additionh, subtractionh
JUMPS

;================================================================
;Main
;===============================================================
Main PROC
  mov     ax,@data
  mov     ds,ax

  cout    prompt1                   ;Print 1st prompt
  getnum  num1                      ;Get 1st number from input.
  cout    endl
  cout    prompt2                   ;Print 2nd Prompt.
  getnum  num2                      ;Get 2nd number from input.
  cout    endl
  call    Dec2Hex                   ;Convert numbers to Hex from Dec.
  addhex  num1h,num2h,additionh     ;Add the two hex numbers.
  subhex  num1h,num2h,subtractionh  ;Subtract the two hex numbers.
  call    Hex2Dec                   ;Convert back into Dec from Hex.
  cout    endl
  showresult                        ;Display Results
  dos_return

Main ENDP
END Main
