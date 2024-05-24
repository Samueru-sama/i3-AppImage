#!/bin/sh

# Patched version that merges a PR that fixes an issue when moving multiple windows
# https://github.com/i3/i3/pull/5521 https://github.com/i3/i3/issues/5382

set -u
ARCH=x86_64
APP=i3
APPDIR="$APP.AppDir"
REPO="https://github.com/Samueru-sama/i3.git"
EXEC="$APP"

LINUXDEPLOY="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-static-x86_64.AppImage"
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')

# CREATE DIRECTORIES
[ -n "$APP" ] && mkdir -p ./"$APP/$APPDIR" && cd ./"$APP/$APPDIR" || exit 1

# DOWNLOAD AND BUILD i3
CURRENTDIR="$(dirname "$(readlink -f "$0")")" # DO NOT MOVE THIS
git clone --recursive "$REPO" && cd i3 && meson setup build -Dprefix="$CURRENTDIR/usr" -Ddefault_library=static -Dmans=false -Ddocs=false \
&& ninja -C build && ninja -C build install && cd .. && rm -rf ./i3 ./usr/share/doc || exit 1

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$PATH:$CURRENTDIR/usr/bin"
"$CURRENTDIR/usr/bin/i3" "$@"
EOF
chmod a+x ./AppRun

APPVERSION=$(./AppRun --version | awk '{print $3}')

# Dummy desktop and Icon
rm -rf ./usr/share # The default .desktop just gives too many errors with linuxdeploy.
touch ./i3.png && ln -s ./i3.png ./.DirIcon
cat >> ./"$APP.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=i3
Icon=i3
Exec=i3
Categories=System
Hidden=true
EOF

# MAKE APPIMAGE USING FUSE3 COMPATIBLE APPIMAGETOOL
cd .. && wget "$LINUXDEPLOY" -O linuxdeploy && wget -q "$APPIMAGETOOL" -O ./appimagetool && chmod a+x ./linuxdeploy ./appimagetool \
&& ./linuxdeploy --appdir "$APPDIR" --executable "$APPDIR"/usr/bin/"$EXEC" && VERSION="$APPVERSION" ./appimagetool -s ./"$APPDIR" || exit 1

[ -n "$APP" ] && mv ./*.AppImage .. && cd .. && rm -rf ./"$APP" && echo "All Done!" || exit 1
