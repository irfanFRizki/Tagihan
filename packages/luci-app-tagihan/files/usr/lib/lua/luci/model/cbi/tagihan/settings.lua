-- /usr/lib/lua/luci/model/cbi/tagihan/settings.lua
-- Halaman Pengaturan Tagihan Bot

local m, s, o

m = Map("tagihan", translate("Tagihan Bot"),
    translate("Pengaturan nomor pelanggan dan akun untuk cek tagihan bulanan."))

-- ── Pengaturan Umum ──────────────────────────────
s = m:section(TypedSection, "settings", translate("Pengaturan Umum"))
s.anonymous = true

o = s:option(Flag, "auto_check", translate("Cek Otomatis"))
o.default = "1"
o.rmempty = false

o = s:option(ListValue, "interval", translate("Interval Pengecekan"))
o:value("1",  "Setiap 1 Jam")
o:value("3",  "Setiap 3 Jam")
o:value("6",  "Setiap 6 Jam (Default)")
o:value("12", "Setiap 12 Jam")
o:value("24", "Setiap 24 Jam")
o.default = "6"

-- ── PLN ──────────────────────────────────────────
s = m:section(NamedSection, "pln", "tagihan", translate("PLN Pascabayar"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan"))
o.default = "0"
o.rmempty = false

o = s:option(Value, "idpel", translate("ID Pelanggan"))
o.placeholder = "12 digit nomor ID pelanggan PLN"
o.datatype = "string"
o:depends("enabled", "1")

-- ── PDAM Jakarta (PAM Jaya) ───────────────────────
s = m:section(NamedSection, "pdam", "tagihan", translate("PDAM Jakarta (PAM Jaya)"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan"))
o.default = "0"
o.rmempty = false

o = s:option(Value, "nomor_pelanggan", translate("Nomor Pelanggan"))
o.placeholder = "Nomor pelanggan PDAM (PAM Jaya)"
o.datatype = "string"
o:depends("enabled", "1")

-- ── WiFi (MyRepublic) ─────────────────────────────
s = m:section(NamedSection, "wifi", "tagihan", translate("WiFi MyRepublic"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan"))
o.default = "0"
o.rmempty = false

o = s:option(Value, "email", translate("Email MyRepublic"))
o.placeholder = "email@contoh.com"
o.datatype = "string"
o:depends("enabled", "1")

o = s:option(Value, "password", translate("Password"))
o.placeholder = "password akun MyRepublic"
o.password = true
o:depends("enabled", "1")

return m
