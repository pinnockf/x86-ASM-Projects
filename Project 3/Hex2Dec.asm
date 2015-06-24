;===============================================================
; Hex2Dec
;
; This is a subprogram for project 3 that takes two numbers
; stored in memory as hex, and converts them to their  decimal
; equivalents to be displayed
;===============================================================
.Model small

.DATA
addition    db 5 DUP (?),'$'
subtraction db 5 DUP (?),'$'

.CODE
Extrn   additionh,subtractionh
Public  Hex2Dec, addition, subtraction

Hex2Dec PROC
  push    ax
  push    bx
  push    cx
  push    dx

  mov     ax,               additionh
  mov     si,               4
  mov     bx,               10
  mov     cx,               5

Division_Loop_For_Addition:
  mov     dx,               0
  div     bx
  add     dl,               '0'
  mov     addition+[si],    dl
  dec     si
  loop    Division_Loop_For_Addition

  mov     ax,               subtractionh
  mov     si,               4
  mov     bx,               10
  mov     cx,               5

Division_Loop_For_Subtraction:
  mov     dx,               0
  div     bx
  add     dl,               '0'
  mov     subtraction+[si], dl
  dec     si
  loop    Division_Loop_For_Subtraction

  pop     dx
  pop     cx
  pop     bx
  pop     ax
  ret
Hex2Dec ENDP
END
