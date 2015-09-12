@ECHO OFF
SETLOCAL
SET EL=0

ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~


IF "%1"=="" ECHO no test.exe && SET ERRORLEVEL=1 && GOTO ERROR
IF "%2"=="" ECHO number of threads missing && SET ERRORLEVEL=1 && GOTO ERROR
IF "%3"=="" ECHO number of iterations missing SET ERRORLEVEL=1 && GOTO ERROR

ECHO %1 0 %3...
%1 --threads 0 --iterations %3
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO %1 %2 %3...
%1 --threads %2 --iterations %3
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0
IF %ERRORLEVEL% NEQ 0 GOTO ERROR



GOTO DONE

:ERROR
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %ERRORLEVEL%
SET EL=%ERRORLEVEL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~

EXIT /b %EL%
