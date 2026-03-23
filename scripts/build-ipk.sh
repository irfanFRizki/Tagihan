#!/bin/bash
set -e

VERSION="${1:-2.3.0}"
ARCH="aarch64_cortex-a72"
REPO_ROOT="$(pwd)"
OUT="${REPO_ROOT}/dist"
WORK="/tmp/ipkbuild$$"

mkdir -p "$OUT"
rm -rf "$WORK"

echo ""
echo "=== Build luci-app-tagihan v${VERSION} ==="
echo "=== REPO_ROOT: ${REPO_ROOT} ==="
echo ""

# Debug: tampilkan isi packages/
echo "--- Isi packages/ ---"
find packages/ -type f | sort
echo "---------------------"
echo ""

pack() {
    local NAME="$1" VER="$2" DEPS="$4" DESC="$5" MAINT="$6"
    local SRC="${REPO_ROOT}/$7"
    local IPK="${NAME}_${VER}_${ARCH}.ipk"
    local D="${WORK}/${NAME}"

    echo "=> $IPK"
    echo "   SRC = $SRC"

    if [ ! -d "$SRC" ]; then
        echo "   ERROR: folder tidak ditemukan: $SRC"
        echo "   Isi REPO_ROOT:"
        ls -la "${REPO_ROOT}/"
        echo "   Isi packages/:"
        ls -la "${REPO_ROOT}/packages/" 2>/dev/null || echo "   packages/ tidak ada"
        exit 1
    fi

    echo "   Files: $(find "$SRC" -type f ! -path '*/.postinst/*' | wc -l)"

    mkdir -p "$D/data" "$D/ctrl"
    printf '2.0\n' > "$D/debian-binary"

    # Copy semua file kecuali .postinst
    for item in "$SRC"/*/; do
        [ -e "$item" ] || continue
        dirname=$(basename "$item")
        [ "$dirname" = ".postinst" ] && continue
        cp -r "$item" "$D/data/"
    done

    # Fix permission
    find "$D/data" -name "*.sh" -exec chmod 755 {} \; 2>/dev/null || true
    find "$D/data/usr/bin" -type f -exec chmod 755 {} \; 2>/dev/null || true
    find "$D/data/etc/init.d" -type f -exec chmod 755 {} \; 2>/dev/null || true
    find "$D/data/etc/uci-defaults" -type f -exec chmod 755 {} \; 2>/dev/null || true

    echo "   data/ files: $(find "$D/data" -type f | wc -l)"
    (cd "$D/data" && tar -czf "$D/data.tar.gz" --numeric-owner --owner=0 --group=0 .)

    # postinst
    if [ -f "$SRC/.postinst/postinst" ]; then
        cp "$SRC/.postinst/postinst" "$D/ctrl/postinst"
    else
        printf '#!/bin/sh\n[ "${IPKG_NO_SCRIPT}" = "1" ] && exit 0\n[ -s ${IPKG_INSTROOT}/lib/functions.sh ] || exit 0\n. ${IPKG_INSTROOT}/lib/functions.sh\ndefault_postinst $0 $@\nexit 0\n' > "$D/ctrl/postinst"
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

    (cd "$D/ctrl" && tar -czf "$D/control.tar.gz" --numeric-owner --owner=0 --group=0 .)

    cd "$D"
    tar -czf "${OUT}/${IPK}" --numeric-owner --owner=0 --group=0 \
        debian-binary data.tar.gz control.tar.gz

    echo "   [OK] dist/${IPK} ($(du -sh "${OUT}/${IPK}" | cut -f1))"
}

pack tagihan "$VERSION" "$ARCH" \
    "python3-light,python3-urllib3" \
    "Tagihan Bot - Cek tagihan PLN PDAM WiFi" \
    "irfanFRizki" \
    "packages/tagihan/files"

pack luci-app-tagihan "$VERSION" "$ARCH" \
    "tagihan,luci-base" \
    "LuCI untuk Tagihan Bot" \
    "irfanFRizki" \
    "packages/luci-app-tagihan/files"

rm -rf "$WORK"
echo ""
echo "=== Selesai ==="
ls -lh "$OUT"/*.ipk
