; Источник - https://board.flatassembler.net/topic.php?p=150882
format pe console

include 'win32ax.inc'

entry main

section '.data' data readable writeable

strHello db 'Hello, world !',13,10,0
strPause db 'pause',0

section '.txt' code executable readable

main:
       cinvoke printf,strHello
       cinvoke system,strPause

       push 0
       call [ExitProcess]
      
section '.import' import data readable

library kernel32,'kernel32.dll',\
    msvcrt,'msvcrt.dll'

import kernel32,\
          ExitProcess,'ExitProcess'
import msvcrt,\
          printf,'printf',\
          system,'system'
