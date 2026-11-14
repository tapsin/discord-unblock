@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "ZAPRET_URL=https://github.com/bol-van/zapret/releases/download/v72.13/zapret-v72.13.zip"
set "ZIP=%TEMP%\zapret-v72.13.zip"
set "EXT=%TEMP%\zapret-extract"

if exist "%~dp0\winws.exe" goto :run

echo Discord Unblock: Zapret indiriliyor...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%ZAPRET_URL%' -OutFile '%ZIP%' -UseBasicParsing"
if not exist "%ZIP%" (
  echo HATA: Indirme basarisiz.
  del /q "%ZIP%" 2>nul
  exit /b 1
)

if exist "%EXT%" rmdir /s /q "%EXT%"
if not exist "%EXT%" mkdir "%EXT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '%EXT%' -Force"

if not exist "%EXT%\zapret-v72.13\binaries\windows-x86_64\winws.exe" (
  echo HATA: Cikarma basarisiz.
  del /q "%ZIP%" 2>nul
  exit /b 1
)

echo Zapret dosyalari DNS klasorune kopyiliyor...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$src = '%EXT%\zapret-v72.13\binaries\windows-x86_64'; $dst = '%~dp0'; foreach($f in @('winws.exe','WinDivert.dll','WinDivert64.sys','cygwin1.dll')){ Copy-Item -LiteralPath (Join-Path -Path $src -ChildPath $f) -Destination $dst -Force }"

:run
echo Discord bypass calisiyor...
start "" "%~dp0\winws.exe" --wf-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6

endlocal
exit /b 0
