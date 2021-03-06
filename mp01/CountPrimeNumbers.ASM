; �����������   ���������, ����������� �����
; ������� ����� � ��������� �� 1 �� ��������� ����� ��� �����.
format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable
        ; �������������� ������, ��������� � �������.
        strAskInput   db 'Please enter a number bigger than 0.',10, 0
        strInvalidInput db 'Number must not be equal to 0. Please try again.',10, 0
        strFoundPrimes   db 'There are %d prime numbers in range from 1 to %d.',10,0
        strInvalidFormat db 'Invalid input format, seems like you passed a string. Terminating the process.',10,0
        strEnd           db 'Press any key to exit the program.',10,0
        ; ������ - �������� ��� ������� scanf.
        strScanUInt   db '%u', 0


        number       dd 0 ; �������� ������������� �����
        count        dd 0 ; ������� ���������� ������� �����
        i            dd 5 ; ����������, ������������ � ����� ��� ����������� �������� �����
        currentNum   dd 1 ; ��������� �����, ������� ����� ��������� �� ��������
        isPrime      dd 0 ; 1, ���� ����� �������, 0 � ��������� ������


;--------------------------------------------------------------------------

section '.code' code readable executable
start:
; 1) ���� ����� �������������
        call NumberInput

; 2) ������ �� ������ �� 1 �� ��������� �������������
; ����� � ������� ���������� ������� �����.
        call CountPrimes
; 3) ����� ���������� �� �����
        push [number]
        push [count]
        push strFoundPrimes
        call [printf]
        add esp, 12

finish:
        push strEnd
        call [printf]
        add esp, 4

; �������� ����������������� ����� ����� ��������� ���������
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------

NumberInput:
        push strAskInput
        call [printf] ; ������� ������, ������������� ���� � ������������
        add esp, 4

        push number
        push strScanUInt
        call [scanf] ; ������ ���������������� ����
        add esp, 8

        ; ���������, ������� ���������� ��������� ������� ������� scanf.
        ; ���� 0 - ������ ���� ��� ���������� �����������.
        cmp eax, 0
        je incorrectFormat

        ; �������� ��������� ������������� �������� �� ��������� ����.
        cmp [number], 0
        je wrongInput
        jmp endInput ; ���� ���� ��� ���������� �������� - ������� �� ������������

wrongInput: ; ���� ������������ ��� 0.
        push strInvalidInput
        call [printf] ; ����� ��������� �� ������
        add esp, 4
        jmp NumberInput ; ��������� ������� ������� �����

incorrectFormat: ; ���� ����������� ��� ������ ����� �����
        push strInvalidFormat
        call [printf] ; ����� ��������� �� ������
        add esp, 4
        jmp finish

endInput:
        ret ; ����� �� ������������

;--------------------------------------------------------------------------

CheckIfPrime: ; ���������, �������� �� ����� [currentNum] �������
; ���������� ����� ����������� ��������, ��������� �� ��������� ���� ������.
; https://en.wikipedia.org/wiki/Primality_test#Python_Code
        cmp [currentNum], 3
        jbe numIsSmall ; ���� ����� <= 3, �� ����� ���������� �������� ����������

        ; ���� ����� ���������� �������, �� ������� ��������� ��� ��������� �� 2 � �� 3
        xor edx, edx
        mov eax, [currentNum]
        mov ebx, 2
        div ebx ; �������� ��������� �� 2. ������� ��������� � edx
        cmp edx, 0
        je setFalse ; ���� ����� ������ 2 - ��� �� �������
        ; ���������� � ���������� �� 3
        xor edx, edx
        mov eax, [currentNum]
        mov ebx, 3
        div ebx ; �������� ��������� �� 3
        cmp edx, 0
        je setFalse ; ���� ����� ������ 3 - ��� �� �������

        ; ������ ��������� ������ �� ���������: ����������
        ; ��� ������� �����, ������� ����� ������� 1 � 5 ��� ������� �� 6
        mov [i], 5

checkLoop: ; ����� ����� while

        mov eax, [i]
        xor edx, edx ; �������� ������� edx
        mul [i] ; eax = i * i

        cmp eax, [currentNum] ; ���������� i*i � n
        jg setTrue ; ���� i*i > n, �� ����� ������� (�� ������� ���������)
        ; ���������� ���� �����
        ; ���� i*i <= n:
        ; ������� ���������, ���� n % i == 0
        mov eax, [currentNum] ; � eax �������� �������
        mov ebx, [i] ; � ebx �������� ��������
        xor edx, edx
        div ebx ; ����� n �� i � ��������
        cmp edx, 0 ; n % i == 0?
        je setFalse ; ����� ���������� ������ �� i, ������ �� �������

        ; ����������� �������� �� n % (i + 2) == 0
        mov eax, [currentNum] ; � eax �������� �������
        mov ebx, [i]
        add ebx, 2 ; � ebx �������� �������� = i + 2
        xor edx, edx
        div ebx ; ����� n �� i + 2 � ��������
        cmp edx, 0 ; n % (i + 2) == 0?
        je setFalse ;����� ���������� ������ �� i + 2, ������ �� �������

        ; ���������� i �� 6
        mov eax, [i]
        add eax, 6
        mov [i], eax

        ;��������� �� ��������� �������� ����� while
        jmp checkLoop


numIsSmall: ; ������� ���� ����������, ���� �������� ����� <= 3
        cmp [currentNum], 1
        ja setTrue
        jmp setFalse

setTrue: ; ������������� ���� �������� ����� � �������� 1
        mov [isPrime], 1
        jmp endCheck

setFalse: ; ������������� ���� �������� ����� � �������� 0
        mov [isPrime], 0
        jmp endCheck

endCheck:
        ret

;--------------------------------------------------------------------------
CountPrimes:
; ������������ ���-�� ������� ����� �� 1 �� ���������� �����

        mov [currentNum], 1 ; �������� ������� � 1
        ; ������ ������� ����� ����� ������ �������� (��� ��� ����������� ����),
        ; �� ���������� ������������ ������ ������� ����� - 2. ��� ����� ������
        ; ����� ��������.

        cmp [number], 2
        jae addTwo
        jmp countLoop

addTwo: ; ����������� ������� ������� ����� �� 1, ���� �������� ���� >= 2.
        mov ecx, [count]
        add ecx, 1
        mov [count], ecx

countLoop: ; ����� ����� for
        mov eax, [currentNum]
        cmp eax, [number] ; ���������� ������� ����� � ������, �������� �������������
        ja stopCount ; ���� ����� �� ��������� ����� � ��������� ���, �� ������� �� ������������

        ; ����� ��� currentNum ���������, �������� �� ��� �������
        ; ���� ��, �� ����������� ������� count �� 1.
        call CheckIfPrime ; ���������, �������� �� ������� ����� �������
        cmp [isPrime], 0
        ja incCount  ; ���� ����� �������, �� ���� ������ ��������� ������� ���������� ������� �����
        jmp nextIter ; ���� ����� �� �������, �� ��������� �� ��������� �������� �����

incCount:
        ; ���������� ���������� ������� ����� �� 1
        mov ebx, [count]
        add ebx, 1
        mov [count], ebx

nextIter:
        ; ���� ��������� �����, ���������� ������ �� 2 (�.�. ������� ������ �������� �����)
        mov eax, [currentNum]
        add eax, 2
        mov [currentNum], eax
        jmp countLoop ; ��������� �� ��������� �������� �����

stopCount:
        ret

;-------------------------------������ ������� �������--------------------------
                                                 
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
