@echo off

setlocal enableextensions enabledelayedexpansion

for /f "usebackq" %%i in (`ruby -e"print RUBY_PLATFORM"`) do set platform=%%i

set root=%~dp0
set BUNDLE_GEMFILE=%root%..\Gemfile.%platform%
set task=%1

if exist "%BUNDLE_GEMFILE%" (
   set valid=0
   REM TODO: default to jobs!
   if "%task%" == "jobs" set valid=1
   if "%task%" == "notifications" set valid=1
   if "%task%" == "hooks" set valid=1
   if not "%valid%" == "1" (
     echo usage: itmsworker [jobs^|notifications]
     exit /b 1
  )

  ruby "%root%padrino" rake -c "%root%.." -e production jobs:!task!
) else (
  echo Missing file %BUNDLE_GEMFILE%
  echo You must run: ruby setup.rb
  exit /b 1
)
