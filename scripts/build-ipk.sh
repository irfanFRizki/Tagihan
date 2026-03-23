#!/bin/bash
set -e

VERSION="${1:-1.0.0}"
ARCH="aarch64_cortex-a72"
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
    mkdir -p "$W/data" "$W/ctrl"

    echo "  => Building ${IPK_NAME} ..."

    if [ ! -d "$FILES_SRC" ]; then
        echo "  [ERROR] Folder tidak ada: $FILES_SRC"
        exit 1
    fi

    FILE_COUNT=$(find "$FILES_SRC" -type f ! -path '*/.postinst/*' | wc -l)
    echo "         Source: $FILES_SRC ($FILE_COUNT files)"

    # debian-binary
    printf '2.0\n' > "$W/debian-binary"

    # data.tar.gz — copy semua kecuali .postinst
    find "$FILES_SRC" -mindepth 1 -maxdepth 1 ! -name '.postinst' | while read item; do
        cp -r "$item" "$W/data/"
    done

    if [ -d "$W/data/usr/bin" ]; then
        find "$W/data/usr/bin" -type f -exec chmod 755 {} \;
    fi
    if [ -d "$W/data/etc/init.d" ]; then
        find "$W/data/etc/init.d" -type f -exec chmod 755 {} \;
    fi
    if [ -d "$W/data/etc/uci-defaults" ]; then
        find "$W/data/etc/uci-defaults" -type f -exec chmod 755 {} \;
    fi

    DATA_FILES=$(find "$W/data" -type f | wc -l)
    echo "         data/ berisi $DATA_FILES file"

    (cd "$W/data" && tar -czf "$W/data.tar.gz" \
        --numeric-owner --owner=0 --group=0 .)

    # control.tar.gz
    cat > "$W/ctrl/control" << CTRL
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${PKG_ARCH}
Maintainer: ${PKG_MAINTAINER}
Depends: ${PKG_DEPENDS}
Description: ${PKG_DESC}
CTRL

    if [ -f "${FILES_SRC}/.postinst/postinst" ]; then
        cp "${FILES_SRC}/.postinst/postinst" "$W/ctrl/postinst"
        chmod 755 "$W/ctrl/postinst"
        echo "         postinst: custom"
    else
        cat > "$W/ctrl/postinst" << 'POSTINST'
#!/bin/sh
[ "${IPKG_NO_SCRIPT}" = "1" ] && exit 0
[ -s ${IPKG_INSTROOT}/lib/functions.sh ] || exit 0
. ${IPKG_INSTROOT}/lib/functions.sh
default_postinst $0 $@
exit 0
POSTINST
        chmod 755 "$W/ctrl/postinst"
        echo "         postinst: default"
    fi

    (cd "$W/ctrl" && tar -czf "$W/control.tar.gz" \
        --numeric-owner --owner=0 --group=0 .)

    # outer tar — urutan WAJIB: debian-binary → data → control
    cd "$W"
    tar -czf "${OUTPUT_DIR}/${IPK_NAME}" \
        --numeric-owner --owner=0 --group=0 \
        debian-binary data.tar.gz control.tar.gz

    IPK_SIZE=$(du -sh "${OUTPUT_DIR}/${IPK_NAME}" | cut -f1)
    echo "  [OK] dist/${IPK_NAME} ($IPK_SIZE)"
}

echo ""
echo "=== Building luci-app-tagihan v${VERSION} ==="
echo ""

build_ipk \
    "tagihan" "$VERSION" "$ARCH" \
    "python3-light,python3-urllib3" \
    "Tagihan Bot - Cek tagihan PLN PDAM WiFi tiap bulan" \
    "irfanFRizki" \
    "packages/tagihan/files"

build_ipk \
    "luci-app-tagihan" "$VERSION" "$ARCH" \
    "tagihan,luci-base" \
    "LuCI untuk Tagihan Bot" \
    "irfanFRizki" \
    "packages/luci-app-tagihan/files"

rm -rf "$WORK"
echo ""
echo "=== Build selesai! ==="
ls -lh "$OUTPUT_DIR"/*.ipk

echo ""
echo "=== Verifikasi isi IPK ==="
for ipk in "$OUTPUT_DIR"/*.ipk; do
    echo "[ $(basename $ipk) ]"
    TMPV="/tmp/verify-$$"
    mkdir -p "$TMPV" && cd "$TMPV"
    tar -xzf "$ipk" 2>/dev/null
    echo "  Files: $(tar -tzf data.tar.gz 2>/dev/null | grep -v '/$' | wc -l)"
    tar -tzf data.tar.gz 2>/dev/null | grep -v '/$' | sed 's/^/  /'
    rm -rf "$TMPV"
    cd - > /dev/null
done
