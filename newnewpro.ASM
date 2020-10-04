; Вариант 1
; Разработать программу, которая вводит одномерный массив A[N],
; формирует из элементов массива A массив B, который состоит из положительных элементов массива A

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
    
    N         dd  0   ; под размер A
    Len       dd  0   ; размер полученного массива B
    A         rd  256 ; под массивы
    B         rd  256
    
;--------------------------------------------------------------------------
section '.code' code readable executable
start:

  cinvoke printf, strLen
  push N
  call InputNumber  ; размер массива
  cmp eax, 0        ; проверка ввода длины
je  error
  cmp [N], 0        ; проверка на <= 0
jle error

  ; ввод массива A
  push [N]
  push A
  call InputArray   ; ввод массива A
  cmp  eax, 0       ; проверка ошибки ввода
je  error

; создание массива B
  push [N]          ; передаем размер и адреса массивов
  push A
  push B
  call Transform
  mov  [Len], eax   ; взять размер массива B 

  cinvoke printf, strRes

  cinvoke printf, strResA

  push [N]
  push A
  ; вывод массива A
  call OutputArray

 cinvoke printf, strResB

 push [Len]
  push B
  ; вывод массива B
  call OutputArray   ; вывод массива B


  invoke getch
  invoke ExitProcess, 0

error:
  cinvoke printf, strIncorr

proc  InputNumber
  cinvoke scanf, strFmt, [esp + 4]
  ret 4
endp

;-----------------------Ввод массива-------------------------------------------------

proc InputArray
  ;адрес массива
  mov esi, [esp + 4]
  mov ebx, 0
input:
  cinvoke printf, strElem , ebx
  ; ввод числа  
  push esi
  call InputNumber ; ввод числа
  cmp eax, 0       ; проверка ошибки ввода
  je  exit
  
  ; смещаемся вперед по массиву
  add esi, 4
  ; увеличиваем счетчик
  inc ebx
  cmp ebx, [esp + 8]

jne input   ; зацикливаем ввод до конца
exit:
  ret 8
endp

;--------------------------------Вывод массива --------------------------------------

proc OutputArray
  ;адрес массива
  mov esi, [esp + 4]
  cmp dword [esp + 8], 0
  je  .exit
  mov ebx, 0
.output:
    ; выводим элемент
    cinvoke printf, strElem, ebx
    cinvoke printf, strFmt, [esi]
    cinvoke printf, crlf 

    add esi, 4   ; смещаемся к следующему

    inc ebx      ; увеличиваем счетчик итераций
    ; проверка с N
    cmp ebx, [esp + 8] 
jne .output
.exit:
  ret 8
endp

;----------------Новый массив положительных элементов-----------------------------

proc Transform
  ; берем адреса массивов
  mov edi, [esp + 04]    ; B
  mov esi, [esp + 08]    ; A
  mov ecx, [esp + 12]    ; размер A
  xor ebx, ebx           ; под размер B
.trans:
  ; взять из A
  lodsd
  cmp eax, 0  ; проверка на положительные элементы
  jle .next   ; если <= 0
  ; иначе пишем в массив B
  stosd
  ; увеличить размер B на 1
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