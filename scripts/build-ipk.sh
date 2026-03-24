#!/bin/bash
set -e

VERSION="${1:-3.0.1}"
ARCH="aarch64_cortex-a72"
ROOT="$(pwd)"
OUT="${ROOT}/dist"
WORK="/tmp/ipkbuild$$"

mkdir -p "$OUT"
rm -rf "$WORK"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Build luci-app-tagihan v${VERSION}         "
echo "╚══════════════════════════════════════════╝"
echo ""

pack() {
    local NAME="$1" VER="$2" DEPS="$4" DESC="$5" MAINT="$6"
    local SRC="${ROOT}/$7"
    local IPK="${NAME}_${VER}_${ARCH}.ipk"
    local D="${WORK}/${NAME}"

    echo "► Membangun ${IPK}"
    echo "  Sumber : ${SRC}"

    if [ ! -d "$SRC" ]; then
        echo "  ERROR  : folder tidak ditemukan!"
        exit 1
    fi

    local FCOUNT=$(find "$SRC" -type f ! -path '*/.postinst/*' | wc -l)
    echo "  File   : ${FCOUNT} file"

    mkdir -p "$D/data" "$D/ctrl"
    printf '2.0\n' > "$D/debian-binary"

    # Copy files (exclude .postinst)
    for item in "$SRC"/*/; do
        [ -e "$item" ] || continue
        [ "$(basename $item)" = ".postinst" ] && continue
        cp -r "$item" "$D/data/"
    done
    # Copy juga file langsung di root (bukan folder)
    for item in "$SRC"/*; do
        [ -f "$item" ] || continue
        cp "$item" "$D/data/"
    done

    # Permission
    find "$D/data/usr/bin"        -type f -exec chmod 755 {} \; 2>/dev/null || true
    find "$D/data/etc/init.d"     -type f -exec chmod 755 {} \; 2>/dev/null || true
    find "$D/data/etc/uci-defaults" -type f -exec chmod 755 {} \; 2>/dev/null || true

    local DF=$(find "$D/data" -type f | wc -l)
    echo "  data/  : ${DF} file terkemas"

    (cd "$D/data" && tar -czf "$D/data.tar.gz" \
        --numeric-owner --owner=0 --group=0 .)

    # postinst
    if [ -f "$SRC/.postinst/postinst" ]; then
        cp "$SRC/.postinst/postinst" "$D/ctrl/postinst"
        echo "  postinst: custom"
    else
        printf '#!/bin/sh\n[ "${IPKG_NO_SCRIPT}" = "1" ] && exit 0\n[ -s ${IPKG_INSTROOT}/lib/functions.sh ] || exit 0\n. ${IPKG_INSTROOT}/lib/functions.sh\ndefault_postinst $0 $@\nexit 0\n' \
            > "$D/ctrl/postinst"
        echo "  postinst: default"
    fi
    chmod 755 "$D/ctrl/postinst"

    cat > "$D/ctrl/control" << CTRL
Package: ${NAME}
Version: ${VER}
Architecture: ${ARCH}
Maintainer: ${MAINT}
Depends: ${DEPS}
Description: ${DESC}
CTRL

    (cd "$D/ctrl" && tar -czf "$D/control.tar.gz" \
        --numeric-owner --owner=0 --group=0 .)

    cd "$D"
    tar -czf "${OUT}/${IPK}" \
        --numeric-owner --owner=0 --group=0 \
        debian-binary data.tar.gz control.tar.gz

    local SZ=$(du -sh "${OUT}/${IPK}" | cut -f1)
    echo "  Output : dist/${IPK} (${SZ})"
    echo ""
}

pack "tagihan" "$VERSION" "$ARCH" \
    "python3-light,python3-urllib3" \
    "Tagihan Bot - Cek tagihan PDAM dan WiFi MyRepublic" \
    "irfanFRizki" \
    "packages/tagihan/files"

pack "luci-app-tagihan" "$VERSION" "$ARCH" \
    "tagihan,luci-base" \
    "LuCI interface untuk Tagihan Bot" \
    "irfanFRizki" \
    "packages/luci-app-tagihan/files"

rm -rf "$WORK"

echo "╔══════════════════════════════════════════╗"
echo "║  Build Selesai!                          ║"
echo "╚══════════════════════════════════════════╝"
ls -lh "$OUT"/*.ipk

echo ""
echo "=== Verifikasi isi IPK ==="
for ipk in "$OUT"/*.ipk; do
    echo ""
    echo "[ $(basename $ipk) ]"
    T="/tmp/vfy$$"; mkdir -p "$T"; cd "$T"
    tar -xzf "$ipk" 2>/dev/null
    echo "  Files: $(tar -tzf data.tar.gz 2>/dev/null | grep -v '/$' | wc -l)"
    tar -tzf data.tar.gz 2>/dev/null | grep -v '/$' | sed 's/^/  /'
    rm -rf "$T"; cd "$ROOT"
done
