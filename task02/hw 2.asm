;_ ФИО:      Архаров Дмитрий Павлович                         _______
;_ ГРУППА:   БПИ191                                           _______
;_                                                            _______
;_ ВАРИАНТ:  3                                                _______
;_                                                            _______
;_ ЗАДАНИЕ:  разработать программу, которая вводит одномерный _______
;_           массив А[n], формирует из элементов массива А    _______
;_           новый массив В и выводит его.                    _______
;_                                                            _______
;_           Массив В состоит из сумм соседних элементов A    _______
;_           B = {A[0] + A[1], A[1] + A[2], ...}).            _______

format PE console

entry start

include 'win32a.inc'


;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector A? ', 0
        strVectorA   db 'Vector A:', 10, 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVectorB   db 'Vector B:', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0         ; Size of the vector A
        i            dd ?         ; Loop iterations counter
        tmp          dd ?
        tmpStack     dd ?
        vecA         rd 100
        vecB         rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable

        start:
        ; 1) vector A input
          call VectorInput

        ; 2) out vector A
          push strVectorA
          call [printf]
          call VectorOutA

        ; 3) get vector B
          call VectorB

        ; 4) out vector B
          push strVectorB
          call [printf]
          call VectorOutB

        finish:
        ; Wait untill user press any cey
          call [getch]

        ; End of program
          push 0
          call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jg  getVector
; fail size
        push [vec_size]
        push strIncorSize
        call [printf]

        call [getch]

        push 0
        call [ExitProcess]
; else continue...
getVector:
        push strVectorA
        call [printf]
        add esp, 4

        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorB:
        xor ecx, ecx            ; ecx = 0
        mov edx, vecA            ; edx = &vecA
        mov ebx, vecB            ; ebx = &vecB


vecBLoop:
        cmp ecx, [vec_size]
        je endSumVector      ; to end of loop

        mov [i], ecx


        mov eax, [edx]
        add edx, 4 ; Переходим к A[i+1]

        add [vec_size], -1 ; Проверяем последний ли эллемент перед нами в массве

        cmp ecx, [vec_size]; test for end of mas
        je endSumVector ;я сделал так что если последний эллемент не с кем сумировать то мы просто делаем на 1 эллемент меньше в массиве B

        add [vec_size], 1

        add eax, [edx] ; A[i] + A[i+1]
        add edx, -4  ; Возвращаемся к A[i]
        mov [ebx], eax ; Записываем в B[i] = A[i] + A[i+1]

Next:
        mov ecx, [i]
        inc ecx
        add ebx, 4
        add edx, 4

        jmp vecBLoop


endSumVector:
        ret

;--------------------------------------------------------------------------
VectorOutA:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA            ; ebx = &vecA
putVecALoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVectorA      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecALoop

endOutputVectorA:
        mov esp, [tmpStack]
        ret

;--------------------------------------------------------------------------
VectorOutB: ; По сути такая же подпрограмма как для вывода вектора A
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB            ; ebx = &vecA
putVecBLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVectorB      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecBLoop

endOutputVectorB:
        mov esp, [tmpStack]
        ret

;--------------------------------------------------------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'

    import kernel,\
           ExitProcess, 'ExitProcess'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
