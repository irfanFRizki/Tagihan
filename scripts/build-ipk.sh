#!/bin/bash
set -e

VERSION="${1:-1.0.2}"
ARCH="aarch64_cortex-a72"
# ✅ FIX: gunakan absolute path agar tidak rusak saat cd
OUTPUT_DIR="$(pwd)/dist"
WORK="/tmp/ipk-build-$$"

mkdir -p "$OUTPUT_DIR"

build_ipk() {
    local PKG_NAME="$1"
    local PKG_VERSION="$2"
    local PKG_ARCH="$3"
    local PKG_DEPENDS="$4"
    local PKG_DESC="$5"
    local PKG_MAINTAINER="$6"
    local FILES_SRC="$7"

    local IPK_NAME="${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.ipk"
    local W="${WORK}/${PKG_NAME}"
    mkdir -p "$W"

    echo "  => Building ${IPK_NAME} ..."

    # ── debian-binary ─────────────────────────────────────
    printf '2.0\n' > "$W/debian-binary"

    # ── data.tar.gz ───────────────────────────────────────
    mkdir -p "$W/data"
    if [ -d "$FILES_SRC" ]; then
        cp -r "$FILES_SRC/." "$W/data/"
    fi
    if [ -d "$W/data/usr/bin" ]; then
        find "$W/data/usr/bin" -type f -exec chmod 755 {} \;
    fi
    if [ -d "$W/data/etc/init.d" ]; then
        find "$W/data/etc/init.d" -type f -exec chmod 755 {} \;
    fi
    if [ -d "$W/data/www/cgi-bin" ]; then
        find "$W/data/www/cgi-bin" -type f -exec chmod 755 {} \;
    fi
    (cd "$W/data" && tar -czf "$W/data.tar.gz" \
        --numeric-owner --owner=0 --group=0 \
        .)

    # ── control.tar.gz ────────────────────────────────────
    mkdir -p "$W/ctrl"
    cat > "$W/ctrl/control" << CTRL
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${PKG_ARCH}
Maintainer: ${PKG_MAINTAINER}
Depends: ${PKG_DEPENDS}
Description: ${PKG_DESC}
CTRL

    cat > "$W/ctrl/postinst" << 'POSTINST'
#!/bin/sh
[ "${IPKG_NO_SCRIPT}" = "1" ] && exit 0
[ -s ${IPKG_INSTROOT}/lib/functions.sh ] || exit 0
. ${IPKG_INSTROOT}/lib/functions.sh
default_postinst $0 $@
exit 0
POSTINST
    chmod 755 "$W/ctrl/postinst"

    (cd "$W/ctrl" && tar -czf "$W/control.tar.gz" \
        --numeric-owner --owner=0 --group=0 \
        .)

    # ── outer tar ─────────────────────────────────────────
    # ✅ KRITIS: cd ke W dulu, lalu pakai OUTPUT_DIR absolute
    # Urutan: debian-binary → data.tar.gz → control.tar.gz
    # Entry names: TANPA ./ prefix
    cd "$W"
    tar -czf "${OUTPUT_DIR}/${IPK_NAME}" \
        --numeric-owner --owner=0 --group=0 \
        debian-binary data.tar.gz control.tar.gz

    echo "  [OK] dist/${IPK_NAME}"
}

echo ""
echo "=== Building luci-app-tagihan v${VERSION} ==="
echo ""

# Pastikan dist/ ada (redundan tapi aman)
mkdir -p "$OUTPUT_DIR"

# ── Package 1: tagihan (backend Python) ───────────────────
build_ipk \
    "tagihan" \
    "$VERSION" \
    "$ARCH" \
    "python3-light,python3-urllib3" \
    "Tagihan Bot - Cek tagihan PLN PDAM WiFi tiap bulan" \
    "irfanFRizki" \
    "packages/tagihan/files"

# ── Package 2: luci-app-tagihan (LuCI frontend) ───────────
build_ipk \
    "luci-app-tagihan" \
    "$VERSION" \
    "$ARCH" \
    "tagihan,luci-base" \
    "LuCI untuk Tagihan Bot" \
    "irfanFRizki" \
    "packages/luci-app-tagihan/files"

rm -rf "$WORK"
echo ""
echo "=== Build selesai! ==="
ls -lh "$OUTPUT_DIR"/*.ipk
