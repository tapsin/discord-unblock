#!/bin/sh
# AppDir'den AppImage üretir. Çıktı masaüstündeki dns klasörüne kopyalanır.
set -e
cd "$(dirname "$0")"

if [ ! -x appimagetool ]; then
    curl -fsSL -o appimagetool "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool
fi

ARCH=x86_64 ./appimagetool --appimage-extract-and-run AppDir discord-unblock-x86_64.AppImage

mkdir -p "$HOME/Desktop/dns"
cp discord-unblock-x86_64.AppImage "$HOME/Desktop/dns/"
echo "Hazır: $HOME/Desktop/dns/discord-unblock-x86_64.AppImage"
