; �������� ����� ���198
; ����� �������� == 6
; ������� ��������:
; ������� ���������� ������ �.
; ��������� ������ B �� ��������� �,
; �������� ������� ������ ��������� ����� x.

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
; 1) ���� x, ���� ������� �
        call VectorInput
; 2) ������������ ������� B
        call FormVectorB
; 3) ����� ������� �
       ; call VectorOutA
; 4) ����� ������� B
        call VectorOutB
finish:
; �������� ����������������� ����� ����� ��������� ���������
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------

VectorInput:

        push strXValue
        call [printf]  ; ������� ������, ������������� ���� ����� x
        add esp, 4

        push x
        push strScanInt
        call [scanf] ; ��������� x
        add esp, 8

        push strVecSize
        call [printf] ; ������� ������, ������������� ���� ������� �������
        add esp, 4 ; ������� �����

        push vec_size
        push strScanInt
        call [scanf] ; ���������� ������� �������, ������ ��������� ����� � ���������� vec_size
        add esp, 8 ; ������� �����

        mov eax, [vec_size] ; ����������� �������� vec_size � ������� eax
        cmp eax, 0 ; ��������� vec_size � ����
        jg  getVector ; ���� vec_size > 0 - ��������� � ����� GetVector
; �����:
        push [vec_size]
        push strIncorSize
        call [printf]  ; ������� ��������� � �������� ������� �������.
        add esp, 8
        jmp finish ; ������� � ����� ������ �� ���������

; ��������� � ���� �����, ���� �� ������ � �������� ������ ������� > 0
getVector:
        xor ecx, ecx            ; �������� ������� ecx
        mov ebx, vec            ; ebx = &vec

getVecLoop: ; ���� ���������� ��������� �������
        mov [tmp], ebx ; ��������� ������

        cmp ecx, [vec_size]  ; ���������� �������� � �������� ecx � �������� �������
        jge endInputVector       ; ���� >= - ������� �� �����

        ; ���������� �������� �������
        mov [i], ecx ; ��������� ������

        push ecx
        push strVecElemI
        call [printf] ; ������� ������, ������������� ���� ���������� �������� �������
        add esp, 8 ; ���c��� �����

        push ebx
        push strScanInt
        call [scanf] ; ��������� ��������� ������� �������
        add esp, 8 ; ������� �����

        mov ecx, [i] ; ��������������� ������
        inc ecx ; ���������� ������� �� 1
        mov ebx, [tmp] ; ��������������� ������
        add ebx, 4 ; �������� ������ �� 4 �����, ����� ����� ���� �������� � ���� ��������� �������
        jmp getVecLoop ; ��������� �� ��������� �������� �����
endInputVector:
        ret ; ����� �� ������������ VectorInput

;--------------------------------------------------------------------------

FormVectorB:
        mov [tmpStack], esp     ; ���������� �������� ��������� ����� - ��� ����� ������ ������� ��� �� ����� �����
        xor ecx, ecx            ; ��������� �������� ecx
        mov eax, vec            ; eax = &vec
        mov ebx, vecB           ; ebx = &vecB

CheckVecLoop:
        mov [tmp], eax ; ��������� ������ �� ������ �
        mov [tmpB], ebx ; ��������� ������ �� ������ B
        cmp ecx, [vec_size]     ; ��������� ������� � ������� �������
        je endCheck      ; ����� �� �����, ���� �������� �� ����� �������
        mov [i], ecx ; ��������� ������� ������


        mov eax, [tmp]
        mov ecx, [eax]
        mov eax, ecx  ; ������ � eax � ecx ����� ��������������� ������� ������� (�������)
        mov ebx, [x] ; ���������� � ebx ��������
        mov edx, 0

        cmp [x], 0  ; ���������� �������� � ����
        jne notNullDiv ; ���� x!= 0 - ��������� � ����� notNullDiv
        push strZero
        call [printf]
        add esp, 4
        jmp finish ; ���� x ����� 0 - ������� ��������� �� ������ � ������� �� ���������


notNullDiv:

        div ebx ; ���������� �������� �������. ������� �� ������� ��������� � edx
        cmp edx, 0 ; ���������� ������� �� ������� � ����
        jne notZero ; ���� ������� ��������� - ��������� � ����� notZero

        mov eax, [tmp] ; �����: ���������� ������ �� ������ � � eax
        mov ebx, [tmpB] ; ���������� ������ �� ������ B � ebx
        mov [ebx], ecx  ; ���������� � ������ B ������� ������� �� �, �.�. �� ������������� �������

        mov ecx, [i] ; ��������������� ������
        inc ecx   ; ����������� ������ i �� ����
        add eax, 4
        add ebx, 4

        xor edx, edx
        mov edx, [count]
        inc edx  ; ����������� ������� ����� ��������� � ������� B �� 1
        mov [count], edx

        jmp CheckVecLoop ; ������� �� ��������� �������� �����


notZero: ; ���� ������� �� A �� ������ x, �� ���� ������� �� ������� != 0
        mov ecx, [i] ; ��������������� ������
        inc ecx ; ����������� ������ �� 1
        mov eax, [tmp] ; ��������������� ������ A
        add eax, 4 ; �������� ������ �� 4 �����, ����� ����� ���� ���������� � ���������� ��������
        mov ebx, [tmpB] ; ��������������� ������ B

        jmp CheckVecLoop ; ������� �� ��������� �������� �����


endCheck:
        mov esp, [tmpStack] ; ���������� ���� � ������ ���������
        ret

;--------------------------------------------------------------------------

VectorOutA: ; ����� ������� � - � ������ ������� �� ���������
        mov [tmpStack], esp     ; ���������� �������� ��������� ����� - ��� ����� ������ ������� ��� �� ����� �����
        xor ecx, ecx            ; ��������� �������� ecx
        mov ebx, vec            ; ebx = &vec
putVecLoop:
        mov [tmp], ebx ; ��������� ������
        cmp ecx, [vec_size]     ; ��������� �������� � ������ �������
        je endOutputVector      ; ����� �� �����, ���� �������� �� ���� ���������
        mov [i], ecx ; ��������� ������

        ; ����� �������� ������� A
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i] ; ��������������� ������
        inc ecx ; ����������� ������ �� 1
        mov ebx, [tmp] ; ��������������� ������
        add ebx, 4 ; �������� ������ �� 4 �����, ����� ����� ���� ���������� � ���������� ��������
        jmp putVecLoop ; ������� �� ��������� �������� �����
endOutputVector:
        mov esp, [tmpStack] ; ���������� ���� � ������ ���������
        ret

;-------------------------------------------------------------------

VectorOutB:
        mov [tmpStack], esp     ; ���������� �������� ��������� ����� - ��� ����� ������ ������� ��� �� ����� �����
        xor ecx, ecx            ; ��������� �������� ecx
        mov ebx, vecB            ; ebx = &vecB
putVecLoopB:
        mov [tmp], ebx ; ��������� ������
        cmp ecx, [count] ; ��������� �������� � ������ �������
        je endOutputVectorB      ; ����� �� �����, ���� �������� �� ���� ���������
        mov [i], ecx ; ��������� ������

        ; ����� �������� ������� B
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i] ; ��������������� ������
        inc ecx ; ����������� ������ �� 1
        mov ebx, [tmp] ; ��������������� ������
        add ebx, 4 ; �������� ������ �� 4 �����, ����� ����� ���� ���������� � ���������� ��������
        jmp putVecLoopB ; ������� �� ��������� �������� �����
endOutputVectorB:
        mov esp, [tmpStack] ; ���������� ���� � ������ ���������
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

; ��������� ���� ��������� �� ��������� ������:
; 1) ������� ������:
; x = 3, vec_size = 5, A = {1, 3, 5, 6, 7}
; �������� ������:
; B[0] = 3 B[1] = 6
; 2) ������� ������:
; x = 2, vec_size = 6, A = {1, 2, 3, 4, 5, 6}
; �������� ������:
; B[0] = 2, B[1] = 4, B[2] = 6
; 3) ������� ������:
; x = 2, vec_size = 5, A = {-2, -1, 0, 1, 2}
; B[0] = -2, B[1] = 0, B[2] = 2
; 4) ������� ������:
; x = 11, vec_size = 3, A = {1, 2, 3}
; �������� ������:
; 5) ������� ������:
; x = 0, vec_size = 4, A = {1, 2, 3, 4}
; �������� ������: Cannot divide by zero!
; 6) ������� ������:
; x = 3, vec_size = 0
; �������� ������: Incorrect size of vector = 0