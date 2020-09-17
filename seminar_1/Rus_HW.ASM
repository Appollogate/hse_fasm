; Источник - http://datadump.ru/fasm-console-application/
format          PE console 4.0                                ; Консольное приложение.
entry           start                                         ; Точка входа
include         'win32a.inc'                                  ; Делаем стандартное включение описателей.
include         'ENCODING\WIN1251.INC'                        ; Подключить кодировку WIN1251
 
;--- секция кода ---
 
section         '.text' code readable executable
 
  start:
        invoke  SetConsoleOutputCP,1251
        invoke  SetConsoleCP,1251
        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        mov     [stdout], eax
        invoke  GetStdHandle, STD_INPUT_HANDLE
        mov     [stdin], eax
        invoke  WriteConsole,[stdout],cMsg,12,NULL,NULL
        invoke  ReadConsole,[stdin],lpBuffer,1,lpCharsRead,NULL
  exit:
        invoke  ExitProcess, 0
 
;--- секция данных ---
 
section         '.data' data readable writeable
 
cMsg            db      'Привет, мир!'                                  ; Текстовая строка.
lpBuffer        db      10 dup (0)
lpCharsRead     dd      ?                                               ; Количество фактически считанных символов
stdin           dd      ?
stdout          dd      ?
 
;--- секция (таблица) импорта ---
 
section         '.idata' import data readable writeable
 
library         kernel32,'KERNEL32.DLL'
 
import          kernel32,\ 
                GetStdHandle,'GetStdHandle',\ 
                SetConsoleOutputCP,'SetConsoleOutputCP',\
                SetConsoleCP,'SetConsoleCP',\
                WriteConsole,'WriteConsoleA',\
                ReadConsole,'ReadConsoleA',\
                ExitProcess,'ExitProcess'