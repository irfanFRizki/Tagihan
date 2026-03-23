# luci-app-tagihan

IPK OpenWrt untuk cek tagihan bulanan: PLN, PDAM Jakarta, WiFi MyRepublic.

## Install

```sh
opkg remove tagihan luci-app-tagihan 2>/dev/null
opkg install tagihan_*.ipk --nodeps
opkg install luci-app-tagihan_*.ipk --nodeps
/etc/init.d/tagihan enable && /etc/init.d/tagihan start
```

## Buka di LuCI

Services → Tagihan Bot

## Manual check

```sh
tagihan-check all
```
