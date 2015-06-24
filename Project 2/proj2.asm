;FRANKLIN PINNOCK
;CS 14
;Spring 2013
;Project 2

.SALL

.MODEL  SMALL
.STACK  100h
.DATA

UL           DB 218,'$'
UR           DB 191,'$'
LL           DB 192,'$'
LR           DB 217,'$'
horizontal  DB 196,'$'
vertical    DB 179,'$'

Space       DB ' ','$'
NewLine     DB 10,13,'$'
paddingLeft DB 10 DUP (' '),'$'
Line1       DB 12 DUP (' '),'Franklin Pinnock',12 DUP (' '),'$'
Line2       DB 12 DUP (' '),'City University ',12 DUP (' '),'$'
Line3       DB 19 DUP (' '),'Of',19 DUP (' '),'$'
Line4       DB 16 DUP (' '),'New York',16 DUP (' '),'$'

.CODE
start:

;---------------------
;PrintText MACRO
;---------------------
PrintText MACRO text
;save registers
  push    AX
  push    BX
  push    CX
  push    DX

  mov     DX, OFFSET paddingLeft
  mov     ah, 9
  int     21h

  mov     DX, OFFSET Vertical
  int     21h

  mov     DX, OFFSET text
  int     21h

  mov     DX, OFFSET Vertical
  int     21h

  mov     DX, OFFSET newline
  int     21h

;restore registers
  pop     AX
  pop     BX
  pop     CX
  pop     DX
endm

;---------------------
;PrintLine MACRO
;---------------------
PrintLine MACRO begChar,btwChar,endChar
LOCAL startLoop                  ;define Local Label

  push    AX                      ;save registers
  push    BX
  push    CX
  push    DX

  mov     DX, OFFSET paddingLeft ;insert paddingLeft
  mov     ah, 9                   ;DOS: print string
  int     21h                     ;display the message stored in.

;print Beginning Character
  mov     DX,OFFSET begChar
  int     21h


  mov     DX, OFFSET btwChar    ;print Between Character 40 Times
  mov     CX, 40
 startloop:
  int     21h
  loop startloop

  mov     DX,OFFSET endChar     ;print Last Character
  int     21h


  mov     DX,OFFSET NewLine     ;move to next line
  int     21h

  pop     AX                     ;restore registers
  pop     BX
  pop     CX
  pop     DX
endm

  mov     AX,@data
  mov     ds,AX                  ;set DS to point to the data segment


  printLine UL,HORIZONTAL,UR        ;Print Top Line
  printLine Vertical,Space,Vertical
  printLine Vertical,Space,Vertical
  printText Line1
  printLine Vertical,Space,Vertical
  printLine Vertical,Space,Vertical
  printText Line2
  printLine Vertical,Space,Vertical
  printLine Vertical,Space,Vertical
  printText Line3
  printLine Vertical,Space,Vertical
  printLine Vertical,Space,Vertical
  printText Line4
  printLine Vertical,Space,Vertical
  printLine Vertical,Space,Vertical
  printline LL,HORIZONTAL,LR        ;print Bottom Line

  mov     ah,4ch                  ;DOS: terminate program
  mov     al,0                    ;return code will be 0
  int     21h                     ;terminate the program


END start
