set PATH=C:\Users\Lautaro\Desktop\GENERAL\FACULTAD\LyC\compilador\
set LEXICO=Lexico.l
set SINTACTICO=Sintactico.y
set TEST_TXT=Prueba.txt
cd c:\GnuWin32\bin\
pause
flex %PATH%%LEXICO%
pause
bison -dyv %PATH%%SINTACTICO%
pause
cd c:\MinGW\bin\
pause
gcc.exe c:\GnuWin32\bin\lex.yy.c c:\GnuWin32\bin\y.tab.c -o c:\GnuWin32\bin\Prueba.exe
pause
c:\GnuWin32\bin\Prueba.exe %PATH%%TEST_TXT%
pause
del c:\GnuWin32\bin\lex.yy.c
del c:\GnuWin32\bin\y.tab.c
del c:\GnuWin32\bin\y.output
del c:\GnuWin32\bin\y.tab.h
del c:\GnuWin32\bin\Prueba.exe
pause
cd %PATH%