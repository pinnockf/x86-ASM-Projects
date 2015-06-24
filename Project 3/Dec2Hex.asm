;===============================================================
; Dec2Hex
;
; This is a subprogram for project 3 that takes two numbers,
; whose digits are stored in memory as a series of bytes, and
; converts them to a hex number.
;===============================================================
.Model small

.DATA
num1h dw 0
num2h dw 0

.CODE
Extrn num1:byte, num2:byte
Public  Dec2Hex, num1h, num2h

Dec2Hex PROC
  push    ax
  push    bx
  push    cx
  push    dx

  mov     si,     4
  mov     bx,     1
  mov     cx,     10

Next_Place_For_Num1:
  sub     ax,     ax
  mov     al,     num1+[si]
  sub     ax,    '0'
  mul     bx
  add     num1h,  ax
  mov     ax,     bx
  mul     cx
  mov     bx,     ax
  dec     si
  cmp     si,     0
  jge     Next_Place_For_Num1

  pop     dx
  pop     cx
  pop     bx
  pop     ax

  push    ax
  push    bx
  push    cx
  push    dx

  mov     si,     4
  mov     bx,     1
  mov     cx,     10

Next_Place_For_Num2:
  sub     ax,ax
  mov     al,     num2+[si]
  sub     ax,     '0'
  mul     bx
  add     num2h,  ax
  mov     ax,     bx
  mul     cx
  mov     bx,     ax
  dec     si
  cmp     si,     0
  jge     Next_Place_For_Num2

  pop     dx
  pop     cx
  pop     bx
  pop     ax
  ret
Dec2Hex ENDP
END
