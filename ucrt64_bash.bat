@echo off
rem ====== 配置区（按你的安装路径修改） ======
set "MSYS2_ROOT=D:\msys64"
set "DEBUG=0"    rem 设为1可输出调试信息
rem ============================================

rem 保留调用时的当前 Windows 工作目录（%CD% 未被修改）
rem 关键环境变量（要在启动 bash 前设置）
set "MSYSTEM=UCRT64"
set "CHERE_INVOKING=1"
set "MSYS2_PATH_TYPE=inherit"
set "PATH=%MSYS2_ROOT%\ucrt64\bin;%MSYS2_ROOT%\usr\bin;%PATH%"

rem 强制 Windows 控制台使用 UTF-8（conhost）
chcp 65001 >nul

rem 明确要求使用 UTF-8 locale，避免部分程序退回 ANSI/GBK
set "LANG=zh_CN.UTF-8"
set "LC_ALL=zh_CN.UTF-8"

if "%DEBUG%"=="1" (
  echo [wrapper] MSYS2_ROOT=%MSYS2_ROOT%
  echo [wrapper] CWD=%CD%
  echo [wrapper] MSYSTEM=%MSYSTEM%
  echo [wrapper] PATH=%PATH%
  echo [wrapper] LANG=%LANG% LC_ALL=%LC_ALL%
)

rem 直接用登录交互 bash 启动。因为我们没有改变 %CD%，bash 启动后会以调用者目录为当前目录。
"%MSYS2_ROOT%\usr\bin\bash.exe" --login -i %*

exit /b %ERRORLEVEL%

