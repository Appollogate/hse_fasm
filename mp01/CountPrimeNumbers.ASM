; Разработать   программу, вычисляющую число
; простых чисел в диапазоне от 1 до машинного слова без знака.
format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable
        ; Информационные строки, выводимые в консоль.
        strAskInput   db 'Please enter a number bigger than 0.',10, 0
        strInvalidInput db 'Number must not be equal to 0. Please try again.',10, 0
        strFoundPrimes   db 'There are %d prime numbers in range from 1 to %d.',10,0
        strInvalidFormat db 'Invalid input format, seems like you passed a string. Terminating the process.',10,0
        strEnd           db 'Press any key to exit the program.',10,0
        ; Строка - аргумент для функции scanf.
        strScanUInt   db '%u', 0


        number       dd 0 ; Введённое пользователем число
        count        dd 0 ; Счётчик количества простых чисел
        i            dd 5 ; Переменная, используемая в цикле для определения простоты числа
        currentNum   dd 1 ; Очередное число, которое нужно проверить на простоту
        isPrime      dd 0 ; 1, если число простое, 0 в противном случае


;--------------------------------------------------------------------------

section '.code' code readable executable
start:
; 1) Ввод числа пользователем
        call NumberInput

; 2) Проход по числам от 1 до введённого пользователем
; числа и подсчёт количества простых чисел.
        call CountPrimes
; 3) Вывод результата на экран
        push [number]
        push [count]
        push strFoundPrimes
        call [printf]
        add esp, 12

finish:
        push strEnd
        call [printf]
        add esp, 4

; Ожидание пользовательского ввода перед закрытием программы
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------

NumberInput:
        push strAskInput
        call [printf] ; Выводим строку, запрашивающую ввод у пользователя
        add esp, 4

        push number
        push strScanUInt
        call [scanf] ; Читаем пользовательский ввод
        add esp, 8

        ; Проверяем, сколько аргументов корректно считала фунцкия scanf.
        ; Если 0 - значит ввод был осуществлён неправильно.
        cmp eax, 0
        je incorrectFormat

        ; Проверка введённого пользователем значения на равенство нулю.
        cmp [number], 0
        je wrongInput
        jmp endInput ; Если ввод был осуществлён коррктно - выходим из подпрограммы

wrongInput: ; Если пользователь ввёл 0.
        push strInvalidInput
        call [printf] ; Вывод сообщения об ошибке
        add esp, 4
        jmp NumberInput ; Повторяем попытку считать число

incorrectFormat: ; Если пользоватль ввёл строку вмсто числа
        push strInvalidFormat
        call [printf] ; Вывод сообщения об ошибке
        add esp, 4
        jmp finish

endInput:
        ret ; Выход из подпрограммы

;--------------------------------------------------------------------------

CheckIfPrime: ; Проверяет, является ли число [currentNum] простым
; Использует метод определения простоты, описанный по указанной ниже ссылке.
; https://en.wikipedia.org/wiki/Primality_test#Python_Code
        cmp [currentNum], 3
        jbe numIsSmall ; Если число <= 3, то можем определить простоту однозначно

        ; Если число достаточно большое, то сначала проверяем его делимость на 2 и на 3
        xor edx, edx
        mov eax, [currentNum]
        mov ebx, 2
        div ebx ; Проверка делимости на 2. Остаток запишется в edx
        cmp edx, 0
        je setFalse ; Если число кратно 2 - оно не простое
        ; Аналогично с делимостью на 3
        xor edx, edx
        mov eax, [currentNum]
        mov ebx, 3
        div ebx ; Проверям делимость на 3
        cmp edx, 0
        je setFalse ; Если число кратно 3 - оно не простое

        ; Теперь действуем дальше по алгоритму: перебираем
        ; все меньшие числа, которые имеют остаток 1 и 5 при делении на 6
        mov [i], 5

checkLoop: ; Метка цикла while

        mov eax, [i]
        xor edx, edx ; Обнуляем регистр edx
        mul [i] ; eax = i * i

        cmp eax, [currentNum] ; Сравниваем i*i с n
        jg setTrue ; Если i*i > n, то число простое (не нашлось делителей)
        ; Начинается тело цикла
        ; Если i*i <= n:
        ; Сначала проверяем, если n % i == 0
        mov eax, [currentNum] ; В eax помещаем делимое
        mov ebx, [i] ; В ebx помещаем делитель
        xor edx, edx
        div ebx ; Делим n на i с остатком
        cmp edx, 0 ; n % i == 0?
        je setFalse ; Число поделилось нацело на i, значит не простое

        ; Аналогичная проверка на n % (i + 2) == 0
        mov eax, [currentNum] ; В eax помещаем делимое
        mov ebx, [i]
        add ebx, 2 ; В ebx помещаем делитель = i + 2
        xor edx, edx
        div ebx ; Делим n на i + 2 с остатком
        cmp edx, 0 ; n % (i + 2) == 0?
        je setFalse ;Число поделилось нацело на i + 2, значит не простое

        ; Увеличивам i на 6
        mov eax, [i]
        add eax, 6
        mov [i], eax

        ;Переходим на следующую итерацию цикла while
        jmp checkLoop


numIsSmall: ; Переход сюда происходит, если введённое число <= 3
        cmp [currentNum], 1
        ja setTrue
        jmp setFalse

setTrue: ; Устанавливает флаг простоты числа в значение 1
        mov [isPrime], 1
        jmp endCheck

setFalse: ; Устанавливает флаг простоты числа в значение 0
        mov [isPrime], 0
        jmp endCheck

endCheck:
        ret

;--------------------------------------------------------------------------
CountPrimes:
; Подсчитывает кол-во простых чисел от 1 до введённного числа

        mov [currentNum], 1 ; Начинаем считать с 1
        ; Считая простые числа через только нечётные (как это реализовано ниже),
        ; мы пропускаем единственное чётное простое число - 2. Для этого делаем
        ; здесь проверку.

        cmp [number], 2
        jae addTwo
        jmp countLoop

addTwo: ; Увеличиваем счётчик простых чисел на 1, если введённое чило >= 2.
        mov ecx, [count]
        add ecx, 1
        mov [count], ecx

countLoop: ; Метка цикла for
        mov eax, [currentNum]
        cmp eax, [number] ; Сравниваем текущее число с числом, введённым пользователем
        ja stopCount ; Если дошли до введённого числа и проверили его, то выходим из подпрограммы

        ; Иначе для currentNum определям, является ли оно простым
        ; Если да, то увеличиваем счётчик count на 1.
        call CheckIfPrime ; Проверяем, является ли текущее число простым
        cmp [isPrime], 0
        ja incCount  ; Если число простое, то надо сперва увеличить счётчик количества простых чисел
        jmp nextIter ; Если число не простое, то переходим на следующую итерацию цикла

incCount:
        ; Увеличение количества простых чисел на 1
        mov ebx, [count]
        add ebx, 1
        mov [count], ebx

nextIter:
        ; Берём очередное число, увеличивая старое на 2 (т.е. смотрим только нечётные числа)
        mov eax, [currentNum]
        add eax, 2
        mov [currentNum], eax
        jmp countLoop ; Переходим на следующую итерацию цикла

stopCount:
        ret

;-------------------------------Секция импорта функций--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess'

  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
