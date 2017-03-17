@echo off

setlocal enableextensions
set root=%~dp0

if "%1" == "start" goto :start
if "%1" == "stop" goto :stop
if "%1" == "restart" goto :restart

echo "usage: itmsweb <start|stop|restart> [OPTIONS]"
exit /b 1

:start
call :padrino start %2 %3 %4 %5 %6 %7 %8 %9
goto :eof

:stop
call :padrino stop %2 %3 %4 %5 %6 %7 %8 %9
goto :eof

:restart
call :padrino start %2 %3 %4 %5 %6 %7 %8 %9
call :padrino stop %2 %3 %4 %5 %6 %7 %8 %9
goto :eof

:padrino
ruby "%root%padrino" %* -e production -c "%root%.."
