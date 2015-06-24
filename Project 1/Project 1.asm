;FRANKLIN PINNOCK
;CS 14
;Spring 2013
;Project 1

.MODEL  SMALL
.STACK  100h
.DATA

skipline  DB 10,13,'$'   ;declared this because i didnt like all the 10's and 13's running
                          ;running around in my output, I think it looks a bit neater.

line1  DB 3 DUP (' '),29 DUP ('*'),10,13,'$'
line3  DB 9 DUP (' '),'Franklin Pinnock',10,13,'$'
line6  DB 11 DUP (' '),'2928 Cruger Ave',10,13,'$'
line7  DB 11 DUP (' '),'Bronx, NY 10467',10,13,'$'

.CODE
start:

  mov     ax,@data
  mov     ds,ax                   ;set DS to point to the data segment.

;Print Line 1
  mov     dx,OFFSET line1    	  ;set dx to point to the the address of line1.
  mov     ah,9                    ;DOS: print string
  int     21h                     ;display the message stored in line 1.
  push    dx                      ;push the address of line 1 to stack for later use

;Skip a Line
  mov     dx,OFFSET skipline
  int     21h                     ;set dx to point to the the address of skipline.
  push    dx                      ;store the address of skipline for later use


;Print Line 3
  mov     dx,OFFSET Line3
  int     21h

;Skip 2 Lines
  pop     dx                      ;take address of skipline off the stack
  int     21h
  int     21h
  push    dx

;Print Line 6
  mov     dx,OFFSET Line6
  int     21h

;Print Line 7
  mov     dx,OFFSET Line7
  int     21h

;Skipe a Line
  pop     dx
  int     21h

;Print Line 9
  pop     dx                      ;retrieve address of line1 from the stack, line 9 is the
                                  ;same as line 1.
  int     21h

  mov     ah,4ch                  ;DOS: terminate program
  mov     al,0                    ;return code will be 0
  int     21h                     ;terminate the program

END start
