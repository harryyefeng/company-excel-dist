@echo off
chcp 65001 >nul
title 云犀表格 - 自动更新下载器
setlocal enabledelayedexpansion

REM 永远下载最新版（无需修改版本号）：GitHub release "latest" 固定资源名
set "URL=https://github.com/harryyefeng/company-excel-dist/releases/latest/download/CloudSheet-win.zip"
set "OUT=%USERPROFILE%\Downloads\CloudSheet"
set "ZIP=%OUT%\CloudSheet.zip"

echo ============================================
echo   云犀表格 - 下载并更新到最新版
echo ============================================
echo.

echo [1/5] 关闭正在运行的旧程序（避免文件被占用导致更新失败）...
taskkill /F /IM "云犀表格.exe" >nul 2>&1
taskkill /F /IM "Company Excel.exe" >nul 2>&1
timeout /t 2 /nobreak >nul

if not exist "%OUT%" mkdir "%OUT%"

echo [2/5] 下载最新版...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { Invoke-WebRequest -Uri '%URL%' -OutFile '%ZIP%' -UseBasicParsing; Write-Host ('下载完成: ' + [math]::Round((Get-Item '%ZIP%').Length/1MB,1) + ' MB') } catch { Write-Host ('下载失败: ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 (
  echo.
  echo 下载失败。请在浏览器中打开此链接手动下载：
  echo %URL%
  pause
  exit /b 1
)

echo [3/5] 清理旧文件...
REM 删除旧的程序文件夹内容（保留下载的 zip），确保是干净覆盖
for /d %%D in ("%OUT%\*") do rd /s /q "%%D" >nul 2>&1

echo [4/5] 解压...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { Expand-Archive -Path '%ZIP%' -DestinationPath '%OUT%' -Force; Write-Host '解压成功' } catch { Write-Host ('解压失败: ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 (
  echo.
  echo 解压失败，可能是程序还在运行。请手动关闭后重试。
  pause
  exit /b 1
)

echo [5/5] 完成！正在打开...
echo.
echo 安装位置: %OUT%
echo.

REM 找到 exe 并打开（兼容新旧文件名）
if exist "%OUT%\云犀表格.exe" (
  start "" "%OUT%\云犀表格.exe"
) else if exist "%OUT%\Company Excel.exe" (
  start "" "%OUT%\Company Excel.exe"
) else (
  echo 已解压，请进入文件夹手动打开 云犀表格.exe
  explorer "%OUT%"
)

endlocal
