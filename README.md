# Discord Unblock

Discord'un DPI (Deep Packet Inspection) engelini **zapret / nfqws** ile aşan küçük, tek tıkla kullanılabilen bir masaüstü uygulaması.

- **Linux:** `nfqws` + `iptables` (pkexec ile root)
- **Windows:** `winws.exe` + WinDivert (zapret)
- Eksik bağımlılıkları mümkünse kendisi kurar / indirir
- Masaüstü kısayolu ile açılır
- İsterseniz Windows'ta **servis** olarak da çalıştırılabilir

> Bu araç yalnızca kendi cihazınızda, yasal çerçevede kullanılmalıdır.

---

## Linux

### Hazır AppImage ile kurulum

1. [Releases](../../releases) sayfasından `discord-unblock-x86_64.AppImage` dosyasını indirin.
2. Çalıştırılabilir yapın:

   ```bash
   chmod +x discord-unblock-x86_64.AppImage
   ./discord-unblock-x86_64.AppImage
   ```

3. Masaüstü kısayolu için `discord-unblock.desktop` dosyasını masaüstüne kopyalayın ve içindeki `Exec` / `Icon` yollarını kendi konumunuza göre düzenleyin:

   ```ini
   Exec=/tam/yol/discord-unblock-x86_64.AppImage
   Icon=/tam/yol/discord-unblock.png
   ```

### Kaynaktan derleme

```bash
git clone https://github.com/tapsin/discord-unblock.git
cd discord-unblock
./build-appimage.sh
```

`build-appimage.sh` gerekirse `appimagetool`'u indirir ve `discord-unblock-x86_64.AppImage` üretir.

### Gereksinimler

| Bileşen | Paket (Debian/Ubuntu) |
|---|---|
| Python 3 + Tkinter | `python3`, `python3-tk` |
| iptables | `iptables` |
| pkexec | `policykit-1` |
| pkill | `procps` |
| nfqueue kütüphaneleri | `libnetfilter-queue1`, `libnfnetlink0`, `libmnl0` |

Uygulama ilk açılışta eksik paketleri tespit eder ve `pkexec` ile kurmayı dener.

---

## Windows

### Çalıştırma

1. `windows/discord-unblock.ps1` dosyasını indirin.
2. PowerShell'i **Yönetici olarak** açın.
3. Scripti çalıştırın:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\discord-unblock.ps1
   ```

İlk çalıştırmada zapret'in son sürümünden (`v72.13`) şu dosyalar otomatik indirilir ve scriptin yanına kopyalanır:

- `winws.exe`
- `WinDivert.dll`
- `WinDivert64.sys`

### EXE'ye dönüştürme (isteğe bağlı)

```powershell
Install-Module ps2exe -Scope CurrentUser
Invoke-ps2exe .\discord-unblock.ps1 .\discord-unblock.exe -requireAdmin
```

Oluşan `discord-unblock.exe` dosyasını masaüstüne kısayol olarak koyabilirsiniz.

### Windows servisi olarak çalıştırma (isteğe bağlı)

**NSSM** ile:

```powershell
# NSSM indir
$url = 'https://github.com/nssm/nssm/releases/download/v2.24/nssm-2.24.zip'
$zip = "$env:TEMP\nssm.zip"
Invoke-WebRequest $url -OutFile $zip
Expand-Archive $zip -DestinationPath "$env:TEMP\nssm" -Force
$nssm = "$env:TEMP\nssm\nssm-2.24\win64\nssm.exe"

# Servisi kur (exe veya ps1 yolu)
& $nssm install DiscordUnblock "C:\path\to\discord-unblock.exe"
& $nssm set DiscordUnblock AppParameters "--wf-tcp=443 --dpi-desync=fake --dpi-desync-ttl=6"
& $nssm set DiscordUnblock Start SERVICE_AUTO_START
Start-Service DiscordUnblock
```

Servisi kaldırmak için:

```powershell
& $nssm remove DiscordUnblock confirm
```

---

## Nasıl çalışır?

- **Linux:** `nfqws`, 443 portundan çıkan TCP trafiğini NFQUEUE'ya yönlendirir ve DPI'ı atlatmak için sahte paketler üretir. `iptables` kuralı uygulama kapanırken otomatik temizlenir.
- **Windows:** `winws.exe` (zapret) + WinDivert sürücüsü aynı işi yapar. Yönetici yetkisi gerekir.

---

## Notlar

- root / yönetici yetkisi gerekir.
- Bazı antivirüsler `WinDivert` sürücüsünü şüpheli olarak işaretleyebilir; bu bir yanlış pozitiftir.
- `nfqws` ve `winws.exe` [zapret](https://github.com/bol-van/zapret) projesine aittir (MIT lisansı).

## Lisans

MIT
