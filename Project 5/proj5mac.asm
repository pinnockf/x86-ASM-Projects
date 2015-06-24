.SALL
;===============================================================
; proj5mac.asm
;
; This file contains all of the macros used by proj5.asm.
;---------------------------------------------------------------
; INITDATA
;
; Initializes Data Segment
;---------------------------------------------------------------
  INITDATA MACRO
    phone_size   equ 8
    phone        db  phone_size DUP ('$')
    phone_ptr    dw  offset phone

    A_Str        db  2 DUP (?),'$'
    B_Str        db  2 DUP (?),'$'
    C_Str        db  2 DUP (?),'$'
    ABC_Size     equ 2

    A            dw  0
    B            dw  0
    C            dw  0

    X            db  5 DUP (?),'$'
    Y            db  5 DUP (?),'$'
    Z            db  5 DUP (?),'$'
    XYZ_SIZE     equ 5

    ENDL         db 10,13,'$'

    PROMPT_A     db 'A = ','$'
    PROMPT_B     db 'B = ','$'
    PROMPT_C     db 'C = ','$'
    PROMPT_X     db 'X = ','$'
    PROMPT_Y     db 'Y = ','$'
    PROMPT_Z     db 'Z = ','$'
    PROMPT_PH    db 'Phone#? (xxx-xxxx): ','$'
    PROMPT_DOS   db 'Press a key to terminate program: ','$'

    sign_flag    dw 0
  endm
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
;---------------------------------------------------------------
; DOS_Return (End Program)
;---------------------------------------------------------------
  DOS_Return MACRO
      lea     dx,     prompt_DOS
      mov     ah,     09h
      int     21h
      mov     ah,     1                ;return code will be 0
      int     21h                      ;terminate the program
  endm
;---------------------------------------------------------------
; CALCY
;
; Computes and displays the Y line.
;---------------------------------------------------------------
  CALCY MACRO
    ;y = 56*a / (2*b + 3*c)

      mov     ax,     0
      mov     bx,     0
      mov     cx,     0

      mov     ax,     2
      mov     bx,     B
      mul     bx
      mov     cx,     ax  ; cx: 2b
      mov     ax,     3
      mov     bx,     C
      mul     bx          ; ax: 3c
      add     cx,     ax  ; cx: (2b + 3c)

      mov     ax,     56
      mov     bx,     A
      mul     bx          ; ax: 56a

      mov     bx,     cx  ; bx: (2b + 3c)

      div     bx          ; ax: 56a / (2b + 3c)

      push    ax
      push    offset Y
      push    XYZ_SIZE
      Call    PUTDEC

    Display_Prompt_Y:
      lea     dx,     prompt_y
      mov     ah,     09h
      int     21h

    Is_Y_Negative:
      cmp     sign_flag,    0
      je      Display_Y

    Print_Negative_Sign_Y:
      DISPLAYCHR '-'
      dec     sign_Flag

    Display_Y:
      lea     bx,     Y
      mov     si,     0
      mov     ax,     0

      mov     cx,     XYZ_size
    Count_Leading_Zeros_Y:
      cmp     byte ptr bx[si], '0'
      jne     No_More_Leading_Zeros_Y
      inc     ax
      inc     si
      jmp     Count_Leading_Zeros_Y

    No_More_Leading_Zeros_Y:
      mov     di,     ax
    Shift_Elements_Y:
      mov     si,     di
      mov     cx,     ax
    Shift_Elements_Loop_Y:
      cmp     byte ptr bx[di], '$'
      je      Fix_End_Y
      mov     dl,   byte ptr bx[si]
      mov     byte ptr bx[si-1], dl
      dec     si
      loop    Shift_Elements_Loop_Y
      inc     di
      jmp     Shift_Elements_Y

    Fix_End_Y:
      mov     si,     XYZ_Size
      dec     si
      mov     cx,     ax

    Fix_End_Loop_Y:
      mov     dl,     ' '
      mov     byte ptr bx[si], dl
      dec     si
      loop    Fix_End_Loop_Y

      lea     dx,     Y
      mov     ah,     09h
      int     21h

endm
;---------------------------------------------------------------
; CALCZ
;
; Computes and displays the Z line.
;---------------------------------------------------------------
  CALCZ Macro
    ;z = -41a % (6b - 4c)

      mov     ax,     0
      mov     bx,     0
      mov     cx,     0

      mov     ax,     6
      mov     bx,     B
      mul     bx
      mov     cx,     ax ; cx: 6b

      mov     ax,     4
      mov     bx,     C
      mul     bx
      neg     ax          ; ax: -4c
      add     cx,     ax  ; cx: (6b - 4c)

      mov     ax,     41
      mov     bx,     a
      mul     bx
      neg     ax          ;ax: -41a

      cwd
      mov     bx,     cx
      idiv    bx
      mov     cx,     dx  ; dx: -41*a % (6*b - 4*c)
      mov     ax,     dx

      push    ax
      push    offset Z
      push    XYZ_Size
      Call    PUTDEC

    Display_Prompt_Z:
      lea     dx,     prompt_z
      mov     ah,     09h
      int     21h

    Is_Z_Negative:
      cmp     sign_flag,      0
      je      Display_Z

    Print_Negative_Sign_Z:
      DISPLAYCHR '-'
      dec     sign_Flag

    Display_Z:
      lea     bx,     Z
      mov     si,     0
      mov     ax,     0

      mov     cx,     XYZ_size
    Count_Leading_Zeros_Z:
      cmp     byte ptr bx[si], '0'
      jne     No_More_Leading_Zeros_Z
      inc     ax
      inc     si
      jmp     Count_Leading_Zeros_Z

    No_More_Leading_Zeros_Z:
      mov     di,     ax
    Shift_Elements_Z:
      mov     si,     di
      mov     cx,     ax
    Shift_Elements_Loop_Z:
      cmp     byte ptr bx[di], '$'
      je      Fix_End_Z
      mov     dl,   byte ptr bx[si]
      mov     byte ptr bx[si-1], dl
      dec     si
      loop    Shift_Elements_Loop_Z
      inc     di
      jmp     Shift_Elements_Z

    Fix_End_Z:
      mov     si,     XYZ_Size
      dec     si
      mov     cx,     ax

    Fix_End_Loop_Z:
      mov     dl,     ' '
      mov     byte ptr bx[si], dl
      dec     si
      loop    Fix_End_Loop_Z

      lea     dx,     Z
      mov     ah,     09h
      int     21h
  endm
;---------------------------------------------------------------
; DISPLAYCHR
;
; Accepts a character paramater and displays it.
;---------------------------------------------------------------
  DISPLAYCHR MACRO char
      mov     dl,     char
      mov     ah,     02H
      int     21h
  endm
