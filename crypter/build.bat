@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "crypter.obj" del "crypter.obj"
if exist "crypter.exe" del "crypter.exe"

\masm32\bin\ml /c /coff "crypter.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS /section:.rsrc,RW "crypter.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "crypter.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS /section:.rsrc,RW "crypter.obj"
 if errorlevel 1 goto errlink
dir "crypter.*"
goto TheEnd

:errlink
 echo _
echo Link error
goto TheEnd

:errasm
 echo _
echo Assembly Error
goto TheEnd

:TheEnd
 
del *.obj
del *.res

"f:\Program Files\Borland\BDS\3.0\Bin\brcc32.exe" "stub.rc"
copy "f:\Program Files\Borland\BDS\3.0\Bin\stub.res" "stub.res"

pause
