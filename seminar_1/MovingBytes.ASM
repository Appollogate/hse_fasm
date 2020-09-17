; Èñòî÷íèê - https://www.youtube.com/watch?v=kdlgm4m4Tpw
format PE

entry start

include 'win32a.inc'

section '.data' data readable writable

        resStr db 'Result: %d', 0

        NULL = 0

section '.code' code readable executable

        start:
                mov ecx, 110b ;6 â äåñÿòè÷íîé ñèñòåìå ñ÷èñëåíèÿ
                shl ecx, 1 ;ïîáèòîâûé ñäâèã âëåâî íà çàäàííîå çíà÷åíèå

                push ecx
                push resStr
                call [printf]

                call [getch]

                push NULL
                call [ExitProcess]

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'
