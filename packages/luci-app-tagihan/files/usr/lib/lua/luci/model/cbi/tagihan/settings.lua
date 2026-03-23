local m, s, o

m = Map("tagihan", translate("Tagihan Bot — Pengaturan"),
    translate("Konfigurasi layanan tagihan dan notifikasi Telegram."))

-- ── Pengaturan Umum ──────────────────────────
s = m:section(TypedSection, "settings", translate("Umum"))
s.anonymous = true

o = s:option(Flag, "auto_check", translate("Cek Otomatis"))
o.default = "1"; o.rmempty = false

o = s:option(ListValue, "interval", translate("Interval"))
o:value("1","Setiap 1 Jam"); o:value("3","Setiap 3 Jam")
o:value("6","Setiap 6 Jam"); o:value("12","Setiap 12 Jam")
o:value("24","Setiap 24 Jam")
o.default = "6"

-- ── PLN ──────────────────────────────────────
s = m:section(NamedSection, "pln", "tagihan", translate("⚡ PLN Pascabayar"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan"))
o.default = "0"; o.rmempty = false

o = s:option(Value, "idpel", translate("ID Pelanggan"))
o.placeholder = "Contoh: 542100000000 (12 digit)"
o.datatype = "string"
o:depends("enabled","1")

-- ── PDAM ─────────────────────────────────────
s = m:section(NamedSection, "pdam", "tagihan", translate("💧 PDAM Jakarta (PAM Jaya)"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan"))
o.default = "0"; o.rmempty = false

o = s:option(Value, "nomor_pelanggan", translate("Nomor Pelanggan"))
o.placeholder = "Contoh: 000946440"
o:depends("enabled","1")

-- ── WiFi ─────────────────────────────────────
s = m:section(NamedSection, "wifi", "tagihan", translate("📶 WiFi MyRepublic"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan"))
o.default = "0"; o.rmempty = false

o = s:option(Value, "email", translate("Email"))
o.placeholder = "email@contoh.com"
o:depends("enabled","1")

o = s:option(Value, "password", translate("Password"))
o.password = true
o.placeholder = "Password akun MyRepublic"
o:depends("enabled","1")

-- ── Telegram Bot ─────────────────────────────
s = m:section(NamedSection, "telegram", "tagihan", translate("🤖 Notifikasi Telegram"))
s.anonymous = false

o = s:option(Flag, "enabled", translate("Aktifkan Notifikasi"))
o.default = "0"; o.rmempty = false

o = s:option(Value, "bot_token", translate("Bot Token"))
o.placeholder = "1234567890:ABCdefGHIjklMNOpqrSTUvwxYZ"
o.datatype = "string"
o:depends("enabled","1")

o = s:option(Value, "chat_id", translate("Chat ID"))
o.placeholder = "Contoh: 123456789 atau -100123456789 (grup)"
o.description = translate("Kirim pesan ke bot lalu buka t.me/userinfobot untuk cek Chat ID")
o:depends("enabled","1")

o = s:option(Flag, "notify_on_check", translate("Notif Setiap Pengecekan"))
o.default = "1"
o:depends("enabled","1")

return m
