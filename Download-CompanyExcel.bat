@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Company Excel 一键下载器

set "URL=https://github.com/harryyefeng/company-excel-dist/releases/download/v0.1.0/CompanyExcel-v0.1.0-win-x64.zip"
set "OUT=%USERPROFILE%\Downloads\CompanyExcel"
set "ZIP=%OUT%\CompanyExcel.zip"

echo ============================================
echo   Company Excel 安装包 - 多线程极速下载
echo ============================================
echo.
echo 下载位置: %OUT%
echo.

if not exist "%OUT%" mkdir "%OUT%"

echo [1/3] 正在多线程下载(约 30 秒)...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url='%URL%'; $zip='%ZIP%'; $threads=16;" ^
  "$h=curl.exe -sIL $url; $len=0; foreach($line in $h){ if($line -match '(?i)^content-length:\s*(\d+)'){ $len=[long]$matches[1] } };" ^
  "if($len -le 0){ Write-Host '获取文件大小失败, 改用单线程...'; curl.exe -L -o $zip $url; exit };" ^
  "$chunk=[math]::Ceiling($len/$threads); $jobs=@();" ^
  "for($i=0;$i -lt $threads;$i++){ $s=$i*$chunk; $e=[math]::Min($s+$chunk-1,$len-1); if($s -gt $e){break};" ^
  "  $jobs+=Start-Job -ScriptBlock { param($u,$a,$b,$idx,$z) curl.exe -s -L -o ($z+'.part'+$idx) -r ($a.ToString()+'-'+$b.ToString()) $u } -ArgumentList $url,$s,$e,$i,$zip };" ^
  "$jobs | Wait-Job | Out-Null; $jobs | Remove-Job -Force;" ^
  "$fs=[System.IO.File]::Create($zip); for($i=0;$i -lt $jobs.Count;$i++){ $p=$z=$zip+'.part'+$i; if(Test-Path $p){ $bytes=[System.IO.File]::ReadAllBytes($p); $fs.Write($bytes,0,$bytes.Length); Remove-Item $p -Force } }; $fs.Close();" ^
  "Write-Host ('下载完成: ' + ([math]::Round((Get-Item $zip).Length/1MB,1)) + ' MB')"

if not exist "%ZIP%" (
  echo.
  echo 下载失败, 请检查网络后重试, 或直接用浏览器打开:
  echo %URL%
  pause
  exit /b 1
)

echo.
echo [2/3] 正在解压...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '%OUT%' -Force"

echo.
echo [3/3] 完成!
echo.
echo 程序位置: %OUT%\win-unpacked\Company Excel.exe
echo 登录账号: 找管理员获取(例如 admin / Admin@123)
echo.
echo 按任意键打开程序所在文件夹...
pause >nul
explorer "%OUT%\win-unpacked"
endlocal
