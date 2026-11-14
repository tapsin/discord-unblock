# Discord bypass - zapret winws ile (Windows)
# Auto-download: winws.exe + WinDivert driver dosyalarini zapret sürümünden indirir.
# Daha sonra exe'ye donusturmak icin: Invoke-ps2exe .\discord-unblock.ps1 .\discord-unblock.exe -requireAdmin

$ErrorActionPreference = 'Stop'

# Çalisan dizini her zaman .ps1 dosyasinin oldugu dizin olarak al
$here = $PSScriptRoot
if (-not $here) {
    $cmdPath = $MyInvocation.MyCommand.Path
    if ($cmdPath) { $here = Split-Path -Parent $cmdPath }
}
if (-not $here -or -not (Test-Path -LiteralPath $here)) { $here = (Get-Location).Path }

$winws = Join-Path $here 'winws.exe'
$winDivertDll = Join-Path $here 'WinDivert.dll'
$winDivertSys = Join-Path $here 'WinDivert64.sys'
$cygwinDll = Join-Path $here 'cygwin1.dll'

$ZAPRET_URL = 'https://github.com/bol-van/zapret/releases/download/v72.13/zapret-v72.13.zip'
$ZIP_PATH = Join-Path $env:TEMP ("zapret-" + [guid]::NewGuid().ToString("N") + ".zip")
$EXTRACT_DIR = Join-Path $env:TEMP ("zapret-extract-" + [guid]::NewGuid().ToString("N"))

function Remove-Extracted {
    if (Test-Path -LiteralPath $EXTRACT_DIR) { Remove-Item -LiteralPath $EXTRACT_DIR -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $ZIP_PATH) { Remove-Item -LiteralPath $ZIP_PATH -Force -ErrorAction SilentlyContinue }
}

try {
    if (-not (Test-Path -LiteralPath $winws)) {
        Write-Host "winws.exe bulunamadi. Zapret sürümü indiriliyor..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $ZAPRET_URL -OutFile $ZIP_PATH
        Expand-Archive -Path $ZIP_PATH -DestinationPath $EXTRACT_DIR -Force
        # Join-Path sadece iki parametre alir; zincirleyerek kullan
        $srcDir = Join-Path $EXTRACT_DIR 'zapret-v72.13'
        $srcDir = Join-Path $srcDir 'binaries'
        $srcDir = Join-Path $srcDir 'windows-x86_64'
        if (-not (Test-Path -LiteralPath $srcDir)) { throw "winws.exe kaynak dizini bulunamadi: $srcDir" }
        Copy-Item -LiteralPath (Join-Path $srcDir 'winws.exe') -Destination $here -Force
        Copy-Item -LiteralPath (Join-Path $srcDir 'WinDivert.dll') -Destination $here -Force
        Copy-Item -LiteralPath (Join-Path $srcDir 'WinDivert64.sys') -Destination $here -Force
        Copy-Item -LiteralPath (Join-Path $srcDir 'cygwin1.dll') -Destination $here -Force
        Write-Host "winws.exe ve WinDivert driver dosyalari indirildi." -ForegroundColor Green
    }
}
finally {
    Remove-Extracted
}

if (-not (Test-Path -LiteralPath $winws)) {
    Write-Host "HATA: winws.exe hala yok: $winws" -ForegroundColor Red
    Read-Host "Kapatmak icin Enter'a basin"
    exit 1
}

if (-not (Test-Path -LiteralPath $winDivertDll)) {
    Write-Host "HATA: WinDivert.dll yok: $winDivertDll" -ForegroundColor Red
    Read-Host "Kapatmak icin Enter'a basin"
    exit 1
}

if (-not (Test-Path -LiteralPath $winDivertSys)) {
    Write-Host "HATA: WinDivert64.sys yok: $winDivertSys" -ForegroundColor Red
    Read-Host "Kapatmak icin Enter'a basin"
    exit 1
}

if (-not (Test-Path -LiteralPath $cygwinDll)) {
    Write-Host "HATA: cygwin1.dll yok: $cygwinDll" -ForegroundColor Red
    Read-Host "Kapatmak icin Enter'a basin"
    exit 1
}

Set-Location $here
Write-Host "Discord bypass baslatiliyor. Durdurmak icin bu pencereyi kapat veya Ctrl+C." -ForegroundColor Green
& $winws --wf-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6