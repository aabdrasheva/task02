; ������� 1
; ����������� ���������, ������� ������ ���������� ������ A[N],
; ��������� �� ��������� ������� A ������ B, ������� ������� �� ������������� ��������� ������� A

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

    strLen    db  'Input array length: ',0
    strIncorr db  'Wrong array length', 10,0
    strRes    db  'Result', 10,0
    strResA   db  'Array A:', 10,0
    strResB   db  'Array B:', 10,0
    strElem   db  '[%d] : ',0
    strFmt    db  '%d',0
    crlf      db  10, 0
    
    N         dd  0   ; ��� ������ A
    Len       dd  0   ; ������ ����������� ������� B
    A         rd  256 ; ��� �������
    B         rd  256
    
;--------------------------------------------------------------------------
section '.code' code readable executable
start:

  cinvoke printf, strLen
  push N
  call InputNumber  ; ������ �������
  cmp eax, 0        ; �������� ����� �����
je  error
  cmp [N], 0        ; �������� �� <= 0
jle error

  ; ���� ������� A
  push [N]
  push A
  call InputArray   ; ���� ������� A
  cmp  eax, 0       ; �������� ������ �����
je  error

; �������� ������� B
  push [N]          ; �������� ������ � ������ ��������
  push A
  push B
  call Transform
  mov  [Len], eax   ; ����� ������ ������� B 

  cinvoke printf, strRes

  cinvoke printf, strResA

  push [N]
  push A
  ; ����� ������� A
  call OutputArray

 cinvoke printf, strResB

 push [Len]
  push B
  ; ����� ������� B
  call OutputArray   ; ����� ������� B


  invoke getch
  invoke ExitProcess, 0

error:
  cinvoke printf, strIncorr

proc  InputNumber
  cinvoke scanf, strFmt, [esp + 4]
  ret 4
endp

;-----------------------���� �������-------------------------------------------------

proc InputArray
  ;����� �������
  mov esi, [esp + 4]
  mov ebx, 0
input:
  cinvoke printf, strElem , ebx
  ; ���� �����  
  push esi
  call InputNumber ; ���� �����
  cmp eax, 0       ; �������� ������ �����
  je  exit
  
  ; ��������� ������ �� �������
  add esi, 4
  ; ����������� �������
  inc ebx
  cmp ebx, [esp + 8]

jne input   ; ����������� ���� �� �����
exit:
  ret 8
endp

;--------------------------------����� ������� --------------------------------------

proc OutputArray
  ;����� �������
  mov esi, [esp + 4]
  cmp dword [esp + 8], 0
  je  .exit
  mov ebx, 0
.output:
    ; ������� �������
    cinvoke printf, strElem, ebx
    cinvoke printf, strFmt, [esi]
    cinvoke printf, crlf 

    add esi, 4   ; ��������� � ����������

    inc ebx      ; ����������� ������� ��������
    ; �������� � N
    cmp ebx, [esp + 8] 
jne .output
.exit:
  ret 8
endp

;----------------����� ������ ������������� ���������-----------------------------

proc Transform
  ; ����� ������ ��������
  mov edi, [esp + 04]    ; B
  mov esi, [esp + 08]    ; A
  mov ecx, [esp + 12]    ; ������ A
  xor ebx, ebx           ; ��� ������ B
.trans:
  ; ����� �� A
  lodsd
  cmp eax, 0  ; �������� �� ������������� ��������
  jle .next   ; ���� <= 0
  ; ����� ����� � ������ B
  stosd
  ; ��������� ������ B �� 1
  inc ebx
.next:
loop .trans
  mov eax, ebx
  ret 
endp

    
                               
section '.idata' import data readable
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll',\
                user32,'user32.dll'

include 'api\user32.inc'
include 'api\kernel32.inc'

import kernel, ExitProcess, 'ExitProcess'

include 'api\kernel32.inc'
        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'