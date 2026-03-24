# 📋 Tagihan Bot — luci-app-tagihan

IPK OpenWrt untuk monitoring tagihan bulanan via dashboard LuCI.

## Fitur

| Layanan | Metode | Status |
|---|---|---|
| 💧 PDAM Jakarta (PAM Jaya) | API langsung | ✅ |
| 📶 WiFi MyRepublic | IMAP Gmail | ✅ |
| 🤖 Notifikasi Telegram | Bot API | ✅ |
| ⏰ Jadwal Kirim Otomatis | Cron harian/mingguan | ✅ |

## Cara Install

```sh
opkg update
opkg remove tagihan luci-app-tagihan 2>/dev/null
opkg install tagihan_*.ipk --nodeps
opkg install luci-app-tagihan_*.ipk --nodeps
/etc/init.d/tagihan enable
/etc/init.d/tagihan start
```

Buka LuCI → **Services → Tagihan Bot**

## Konfigurasi

### PDAM
Masukkan nomor pelanggan PAM Jaya.

### WiFi MyRepublic (via Gmail)
1. Aktifkan 2FA di akun Gmail
2. Buka `myaccount.google.com/apppasswords`
3. Buat App Password → pilih "Mail"
4. Masukkan email + 16 karakter App Password ke Pengaturan

### Telegram Bot
1. Buat bot via @BotFather, copy token
2. Kirim pesan ke bot, cek Chat ID via @userinfobot
3. Masukkan token + chat ID ke Pengaturan
4. Atur jadwal kirim: harian jam 08:00 atau mingguan tiap Senin

## Manual

```sh
tagihan-check all      # cek semua
tagihan-check pdam     # cek PDAM saja
tagihan-check wifi     # cek WiFi saja
tagihan-notify         # kirim ringkasan ke Telegram
cat /tmp/tagihan-last.log  # lihat log terakhir
```

## Info

- **Maintainer**: irfanFRizki
- **Target**: OpenWrt 24.10.x / Raspberry Pi 4B (aarch64_cortex-a72)
- **Repo**: https://github.com/irfanFRizki/Tagihan
