@echo off
setlocal EnableExtensions
cd /d "%~dp0"

:: --- Yönetici kontrolü ---
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Yonetici yetkisi isteniyor...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

set "ZAPRET_URL=https://github.com/bol-van/zapret/releases/download/v72.13/zapret-v72.13.zip"
set "ZIP=%TEMP%\zapret-v72.13.zip"
set "EXT=%TEMP%\zapret-extract"

:: --- Eksik dosyaları indir ---
if exist "%~dp0winws.exe" goto :check_files

echo.
echo ========================================
echo   Discord Unblock - Zapret indiriliyor...
echo ========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%ZAPRET_URL%' -OutFile '%ZIP%' -UseBasicParsing"
if not exist "%ZIP%" (
  echo [HATA] Indirme basarisiz: %ZIP%
  echo Internet baglantinizi kontrol edin.
  pause
  exit /b 1
)

if exist "%EXT%" rmdir /s /q "%EXT%"
mkdir "%EXT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '%EXT%' -Force"

set "SRC=%EXT%\zapret-v72.13\binaries\windows-x86_64"

if not exist "%SRC%\winws.exe" (
  echo [HATA] Cikarma basarisiz: winws.exe bulunamadi
  rmdir /s /q "%EXT%"
  del /q "%ZIP%"
  pause
  exit /b 1
)

echo.
echo Zapret dosyalari kopyalaniyor...
echo.

copy /y "%SRC%\winws.exe"      "%~dp0" >nul 2>&1
copy /y "%SRC%\WinDivert.dll"  "%~dp0" >nul 2>&1
copy /y "%SRC%\WinDivert64.sys" "%~dp0" >nul 2>&1
copy /y "%SRC%\cygwin1.dll"    "%~dp0" >nul 2>&1

rmdir /s /q "%EXT%"
del /q "%ZIP%"

:check_files
echo.
echo ========================================
echo   Discord Unblock - Dosya kontrolu
echo ========================================
echo.

if not exist "%~dp0winws.exe" (
  echo [HATA] winws.exe bulunamadi
  pause
  exit /b 1
)
echo [OK] winws.exe

if not exist "%~dp0WinDivert.dll" (
  echo [HATA] WinDivert.dll bulunamadi
  pause
  exit /b 1
)
echo [OK] WinDivert.dll

if not exist "%~dp0WinDivert64.sys" (
  echo [HATA] WinDivert64.sys bulunamadi
  pause
  exit /b 1
)
echo [OK] WinDivert64.sys

if not exist "%~dp0cygwin1.dll" (
  echo [HATA] cygwin1.dll bulunamadi
  pause
  exit /b 1
)
echo [OK] cygwin1.dll

:: --- WinDivert driver servisini kontrol et / yukle ---
echo.
echo WinDivert driver kontrol ediliyor...
sc query WinDivert >nul 2>&1
if %errorlevel% neq 0 (
  echo WinDivert servisi yukleniyor...
  sc create WinDivert binPath= "%~dp0WinDivert64.sys" type= kernel >nul 2>&1
  sc start WinDivert >nul 2>&1
)

:: --- Calistir ---
echo.
echo ========================================
echo   Discord bypass baslatiliyor...
echo   Bu pencereyi kapatmayin.
echo   Durdurmak icin Ctrl+C
echo ========================================
echo.

pushd "%~dp0"
winws.exe --wf-tcp=443,80 --dpi-desync=multisplit --dpi-desync-fooling=badseq --dpi-desync-repeats=3 --filter-l7=discord --hostlist-domains=discord.com,gateway.discord.gg,cdn.discordapp.com,api.discordapp.com,ptb.discordapp.com,canary.discordapp.com --dpi-desync-ttl=6
set "EXITCODE=%errorlevel%"
popd

echo.
if not "%EXITCODE%"=="0" (
  echo [HATA] winws.exe cikti: %EXITCODE%
  echo WinDivert driver yuklenemedi olabilir.
  echo Antiviruzu gecici olarak kapatmayi deneyin.
)
echo.
pause
endlocal