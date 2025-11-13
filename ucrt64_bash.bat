@echo off
rem ====== 配置区（按你的安装路径修改） ======
set "MSYS2_ROOT=D:\msys64"
set "DEBUG=0"    rem 设为1可输出调试信息
rem ============================================

rem 保证脚本在 MSYS2 根目录运行（让 msys2 的检测逻辑正确）
pushd "%MSYS2_ROOT%" >nul 2>&1

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

rem 可选：显式设置 HOME（根据需要取消注释并修改）
rem set "HOME=%USERPROFILE%"

if "%DEBUG%"=="1" (
  echo [wrapper] MSYS2_ROOT=%MSYS2_ROOT%
  echo [wrapper] MSYSTEM=%MSYSTEM%
  echo [wrapper] MSYS2_PATH_TYPE=%MSYS2_PATH_TYPE%
  echo [wrapper] PATH=%PATH%
  echo [wrapper] LANG=%LANG% LC_ALL=%LC_ALL%
)

rem 启动 bash 为 login interactive；%* 保留 -c "..." 等参数
"%MSYS2_ROOT%\usr\bin\bash.exe" --login -i %*

set "ERR=%ERRORLEVEL%"
popd >nul 2>&1
exit /b %ERR%

