
REM Run the following command as an administrator in Windows cmd to register the default opening program for the asciio file suffix.
REM assoc .asciio=asciio
REM ftype asciio="D:\msys64\ucrt64_bash.bat" %1

@echo off
rem ====== Configuration area (modify according to your installation path) ======
set "MSYS2_ROOT=D:\msys64"
set "DEBUG=0"    rem Set to 1 to output debugging information
rem ============================================

rem Preserves the current Windows working directory at the time of the call（%CD% not modified）
rem Key environment variables (to be set before starting bash)
set "MSYSTEM=UCRT64"
set "CHERE_INVOKING=1"
set "MSYS2_PATH_TYPE=inherit"
set "PATH=%MSYS2_ROOT%\ucrt64\bin;%MSYS2_ROOT%\usr\bin;%PATH%"

rem Force Windows console to use UTF-8 (conhost)
chcp 65001 >nul

rem Explicitly require the use of UTF-8 locale to avoid some programs falling back to ANSI/GBK
set "LANG=zh_CN.UTF-8"
set "LC_ALL=zh_CN.UTF-8"

if "%DEBUG%"=="1" (
  echo [wrapper] MSYS2_ROOT=%MSYS2_ROOT%
  echo [wrapper] CWD=%CD%
  echo [wrapper] MSYSTEM=%MSYSTEM%
  echo [wrapper] PATH=%PATH%
  echo [wrapper] LANG=%LANG% LC_ALL=%LC_ALL%
)

rem === No parameters: enter interactive bash ===
if "%~1"=="" (
    "%MSYS2_ROOT%\usr\bin\bash.exe" --login -i %*
    exit /b %ERRORLEVEL%
)

rem === With parameters: execute asciio to open the file ===
set "APP=asciio"
set "WIN_FILE=%~1"
set "MSYS_FILE=%WIN_FILE:\=/%"

if "%DEBUG%"=="1" (
    echo [wrapper] WIN_FILE=%WIN_FILE%
    echo [wrapper] MSYS_FILE=%MSYS_FILE%
    echo [wrapper] APP=%APP%
)

rem Enter the MSYS2 login environment, execute the command once and exit
start "" "%MSYS2_ROOT%\usr\bin\bash.exe" --login -c "%APP% \"%MSYS_FILE%\""
exit /b %ERRORLEVEL%

