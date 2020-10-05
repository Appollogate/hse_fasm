; Скрыпина Дарья БПИ198
; Номер варианта == 6
; Условие варианта:
; Считать одномерный массив А.
; Составить массив B из элементов А,
; значение которых кратно введённому числу x.

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strXValue    db 'x? ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVecElemOut  db 'B[%d] = %d', 10, 0
        strZero        db 'Cannot divide by zero!', 10, 0

        vec_size     dd 0
        i            dd ?
        x            dd ?
        count        dd 0
        tmp          dd ?
        tmpB         dd ?
        tmpStack     dd ?
        vec          rd 100
        vecB         rd 100


;--------------------------------------------------------------------------

section '.code' code readable executable
start:
; 1) Ввод x, ввод массива А
        call VectorInput
; 2) Формирование массива B
        call FormVectorB
; 3) Вывод вектора А
       ; call VectorOutA
; 4) Вывод вектора B
        call VectorOutB
finish:
; Ожидание пользовательского ввода перед закрытием программы
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------

VectorInput:

        push strXValue
        call [printf]  ; Выводим строку, запрашивающую ввод числа x
        add esp, 4

        push x
        push strScanInt
        call [scanf] ; Считываем x
        add esp, 8

        push strVecSize
        call [printf] ; Выводим строку, запрашивающую ввод размера массива
        add esp, 4 ; Очистка стека

        push vec_size
        push strScanInt
        call [scanf] ; Считывание размера массива, запись введённого числа в переменную vec_size
        add esp, 8 ; Очистка стека

        mov eax, [vec_size] ; Перемещение значения vec_size в регистр eax
        cmp eax, 0 ; Сравнение vec_size с нулём
        jg  getVector ; Если vec_size > 0 - переходим к метке GetVector
; Иначе:
        push [vec_size]
        push strIncorSize
        call [printf]  ; Выводим сообщение о неверном размере массива.
        add esp, 8
        jmp finish ; Переход к метке выхода из программы

; Переходим к этой метке, если всё хорошо и введённый размер массива > 0
getVector:
        xor ecx, ecx            ; Обнуляем регистр ecx
        mov ebx, vec            ; ebx = &vec

getVecLoop: ; Цикл считывания элементов массива
        mov [tmp], ebx ; Сохраняем массив

        cmp ecx, [vec_size]  ; Сравниваем значение в регистре ecx с размером массива
        jge endInputVector       ; Если >= - выходим из цикла

        ; Считывание элемента массива
        mov [i], ecx ; Сохраняем индекс

        push ecx
        push strVecElemI
        call [printf] ; Выводим строку, запрашивающую ввод очередного элемента массива
        add esp, 8 ; Очиcтка стека

        push ebx
        push strScanInt
        call [scanf] ; Считываем очередной элемент массива
        add esp, 8 ; Очистка стека

        mov ecx, [i] ; Восстанавливаем индекс
        inc ecx ; Увеличение индекса на 1
        mov ebx, [tmp] ; Восстанавливаем массив
        add ebx, 4 ; Сдвигаем массив на 4 байта, чтобы можно было добавить в него следующий элемент
        jmp getVecLoop ; Переходим на следующую итерацию цикла
endInputVector:
        ret ; Выход из подпрограммы VectorInput

;--------------------------------------------------------------------------

FormVectorB:
        mov [tmpStack], esp     ; Сохранение значения указателя стека - так будет удобно вернуть его на место позже
        xor ecx, ecx            ; Обнуление регистра ecx
        mov eax, vec            ; eax = &vec
        mov ebx, vecB           ; ebx = &vecB

CheckVecLoop:
        mov [tmp], eax ; Сохраняем ссылку на массив А
        mov [tmpB], ebx ; Сохраняем ссылку на массив B
        cmp ecx, [vec_size]     ; Сравнение индекса и размера массива
        je endCheck      ; Выход из цикла, если прошлись по всему массиву
        mov [i], ecx ; Сохраняем текущий индекс


        mov eax, [tmp]
        mov ecx, [eax]
        mov eax, ecx  ; Теперь в eax и ecx лежит соответствующий элемент массива (делимое)
        mov ebx, [x] ; Записываем в ebx делитель
        mov edx, 0

        cmp [x], 0  ; Сравниваем делитель с нулём
        jne notNullDiv ; Если x!= 0 - переходим к метке notNullDiv
        push strZero
        call [printf]
        add esp, 4
        jmp finish ; Если x равен 0 - выводим сообщение об ошибке и выходим из программы


notNullDiv:

        div ebx ; Производим операцию деления. Остаток от деления запишется в edx
        cmp edx, 0 ; Сравниваем остаток от деления с нулём
        jne notZero ; если остаток ненулевой - переходим к метке notZero

        mov eax, [tmp] ; Иначе: возвращаем ссылку на массив А в eax
        mov ebx, [tmpB] ; Возвращаем ссылку на массив B в ebx
        mov [ebx], ecx  ; Записываем в массив B текущий элемент из А, т.к. он удовлетворяет условию

        mov ecx, [i] ; Восстанавливаем индекс
        inc ecx   ; Увеличиваем индекс i на один
        add eax, 4
        add ebx, 4

        xor edx, edx
        mov edx, [count]
        inc edx  ; Увеличиваем счётчик числа элементов в массиве B на 1
        mov [count], edx

        jmp CheckVecLoop ; Переход на следующую итерацию цикла


notZero: ; Если элемент из A не кратен x, то есть остаток от деления != 0
        mov ecx, [i] ; Восстанавливаем индекс
        inc ecx ; Увеличиваем индекс на 1
        mov eax, [tmp] ; Восстанавливаем массив A
        add eax, 4 ; Сдвигаем массив на 4 байта, чтобы можно было обратиться к следующему элементу
        mov ebx, [tmpB] ; Восстанавливаем массив B

        jmp CheckVecLoop ; Переход на следующую итерацию цикла


endCheck:
        mov esp, [tmpStack] ; Возвращаем стек в нужное положение
        ret

;--------------------------------------------------------------------------

VectorOutA: ; Вывод массива А - в данном задании не требуется
        mov [tmpStack], esp     ; Сохранение значения указателя стека - так будет удобно вернуть его на место позже
        xor ecx, ecx            ; Обнуление регистра ecx
        mov ebx, vec            ; ebx = &vec
putVecLoop:
        mov [tmp], ebx ; Сохраняем массив
        cmp ecx, [vec_size]     ; Сравнение счётчика с длиной массива
        je endOutputVector      ; Выход из цикла, если прошлись по всем элементам
        mov [i], ecx ; Сохраняем индекс

        ; Вывод элемента массива A
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i] ; Восстанавливаем индекс
        inc ecx ; Увеличиваем индекс на 1
        mov ebx, [tmp] ; Восстанавливаем массив
        add ebx, 4 ; Сдвигаем массив на 4 байта, чтобы можно было обратиться к следующему элементу
        jmp putVecLoop ; Переход на следующую итерацию цикла
endOutputVector:
        mov esp, [tmpStack] ; Возвращаем стек в нужное положение
        ret

;-------------------------------------------------------------------

VectorOutB:
        mov [tmpStack], esp     ; Сохранение значения указателя стека - так будет удобно вернуть его на место позже
        xor ecx, ecx            ; Обнуление регистра ecx
        mov ebx, vecB            ; ebx = &vecB
putVecLoopB:
        mov [tmp], ebx ; Сохраняем массив
        cmp ecx, [count] ; Сравнение счётчика с длиной массива
        je endOutputVectorB      ; Выход из цикла, если прошлись по всем элементам
        mov [i], ecx ; Сохраняем индекс

        ; Вывод элемента массива B
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i] ; Восстанавливаем индекс
        inc ecx ; Увеличиваем индекс на 1
        mov ebx, [tmp] ; Восстанавливаем массив
        add ebx, 4 ; Сдвигаем массив на 4 байта, чтобы можно было обратиться к следующему элементу
        jmp putVecLoopB ; Переход на следующую итерацию цикла
endOutputVectorB:
        mov esp, [tmpStack] ; Возвращаем стек в нужное положение
        ret

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'

; Программа была проверена на следующих тестах:
; 1) Входные данные:
; x = 3, vec_size = 5, A = {1, 3, 5, 6, 7}
; Выходные данные:
; B[0] = 3 B[1] = 6
; 2) Входные данные:
; x = 2, vec_size = 6, A = {1, 2, 3, 4, 5, 6}
; Выходные данные:
; B[0] = 2, B[1] = 4, B[2] = 6
; 3) Входные данные:
; x = 2, vec_size = 5, A = {-2, -1, 0, 1, 2}
; B[0] = -2, B[1] = 0, B[2] = 2
; 4) Входные данные:
; x = 11, vec_size = 3, A = {1, 2, 3}
; Выходные данные:
; 5) Входные данные:
; x = 0, vec_size = 4, A = {1, 2, 3, 4}
; Выходные данные: Cannot divide by zero!
; 6) Входные данные:
; x = 3, vec_size = 0
; Выходные данные: Incorrect size of vector = 0