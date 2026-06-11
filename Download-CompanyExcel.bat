@echo off
chcp 65001 >nul
title 云犀表格 - 下载更新
setlocal

set "URL=https://github.com/harryyefeng/company-excel-dist/releases/latest/download/CloudSheet-win.zip"
set "OUT=%USERPROFILE%\Downloads\CloudSheet"
set "ZIP=%OUT%\CloudSheet.zip"

echo ============================================
echo   云犀表格 - 下载并更新到最新版
echo ============================================
echo.

echo [1/4] 关闭正在运行的旧程序...
taskkill /F /IM "云犀表格.exe" >nul 2>&1
taskkill /F /IM "Company Excel.exe" >nul 2>&1

if not exist "%OUT%" mkdir "%OUT%"

echo [2/4] 正在下载最新版（约110MB，请耐心等待）...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP%' -UseBasicParsing; exit 0 } catch { Write-Host $_.Exception.Message; exit 1 }"
if errorlevel 1 goto downfail

echo [3/4] 正在解压...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Expand-Archive -Path '%ZIP%' -DestinationPath '%OUT%' -Force; exit 0 } catch { Write-Host $_.Exception.Message; exit 1 }"
if errorlevel 1 goto unzipfail

echo [4/4] 完成，正在打开...
if exist "%OUT%\云犀表格.exe" (
  start "" "%OUT%\云犀表格.exe"
) else (
  explorer "%OUT%"
)
echo.
echo 安装位置: %OUT%
echo 如果没有自动打开，请进上面的文件夹双击 云犀表格.exe
echo.
pause
exit /b 0

:downfail
echo.
echo [下载失败] 请检查网络是否能访问 GitHub，或用浏览器打开此链接手动下载：
echo %URL%
echo.
pause
exit /b 1

:unzipfail
echo.
echo [解压失败] 可能是程序还在运行，请手动关闭后重试。
echo.
pause
exit /b 1
