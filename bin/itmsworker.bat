@echo off

setlocal enableextensions

for /f "usebackq" %%i in (`ruby -e"print RUBY_PLATFORM"`) do set platform=%%i

set root=%~dp0
set BUNDLE_GEMFILE=%root%..\Gemfile.%platform%
set task=%1

if exist "%BUNDLE_GEMFILE%" (
  if "%task%" == "" set task=work
  %root%padrino rake -c %root%.. -e production jobs:%task%
) else (
  echo Missing file %BUNDLE_GEMFILE%
  echo You must run: ruby setup.rb
  exit /b 1
)

