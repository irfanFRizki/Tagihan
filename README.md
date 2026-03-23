# luci-app-tagihan

IPK OpenWrt untuk mengecek tagihan bulanan secara otomatis melalui LuCI.

**Layanan yang didukung:**
- ⚡ PLN Pascabayar (via api.pln.co.id)
- 💧 PDAM Jakarta / PAM Jaya (via pelanggan.pamjaya.co.id)
- 📶 WiFi MyRepublic (via member portal)

## Cara Install

```sh
opkg update
opkg remove tagihan luci-app-tagihan 2>/dev/null
opkg install tagihan_*.ipk --nodeps
opkg install luci-app-tagihan_*.ipk --nodeps
/etc/init.d/tagihan enable
/etc/init.d/tagihan start
```

## Cara Konfigurasi

1. Buka LuCI → **Services** → **Tagihan Bot**
2. Klik **Pengaturan**
3. Aktifkan layanan yang ingin dicek, isi nomor pelanggan
4. Simpan dan kembali ke **Dashboard**
5. Klik **Refresh Semua Tagihan**

## Perintah Manual

```sh
# Cek semua tagihan sekarang
tagihan-check all

# Cek hanya PLN
tagihan-check pln

# Cek hanya PDAM
tagihan-check pdam

# Cek hanya WiFi
tagihan-check wifi

# Lihat log terakhir
cat /tmp/tagihan-last.log
```

## Info

- Maintainer: irfanFRizki
- Repo: https://github.com/irfanFRizki/Tagihan
- Target: OpenWrt 24.10.x / aarch64_cortex-a72 (Raspberry Pi 4B)
