@ECHO OFF
IF EXIST "compile.dat" ( del /A compile.dat )
FOR %%f IN ("%CD%\*.sp") DO spcomp64 "%%f" -o "%%~nf.smx"
PAUSE