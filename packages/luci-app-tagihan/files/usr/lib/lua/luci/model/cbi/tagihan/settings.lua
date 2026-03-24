local m, s, o

m = Map("tagihan", translate("Tagihan Bot - Pengaturan"))

-- PDAM
s = m:section(NamedSection, "pdam", "tagihan", translate("PDAM Jakarta (PAM Jaya)"))
s.anonymous = false
o = s:option(Flag,  "enabled", translate("Aktifkan"))
o.default = "0"; o.rmempty = false
o = s:option(Value, "nomor_pelanggan", translate("Nomor Pelanggan"))
o.placeholder = "Contoh: 000946440"
o:depends("enabled","1")

-- WiFi
s = m:section(NamedSection, "wifi", "tagihan", translate("WiFi MyRepublic (via Gmail)"))
s.anonymous = false
o = s:option(Flag,  "enabled", translate("Aktifkan"))
o.default = "0"; o.rmempty = false
o = s:option(Value, "email", translate("Alamat Gmail"))
o.placeholder = "email@gmail.com"
o:depends("enabled","1")
o = s:option(Value, "app_password", translate("Gmail App Password"))
o.password = true
o.placeholder = "xxxx xxxx xxxx xxxx"
o.description = translate("Buat di: myaccount.google.com > Keamanan > Sandi Aplikasi")
o:depends("enabled","1")

-- Telegram
s = m:section(NamedSection, "telegram", "tagihan", translate("Notifikasi Telegram"))
s.anonymous = false
o = s:option(Flag,  "enabled", translate("Aktifkan Notifikasi"))
o.default = "0"; o.rmempty = false
o = s:option(Value, "bot_token", translate("Bot Token"))
o.placeholder = "1234567890:ABCdefGHI..."
o:depends("enabled","1")
o = s:option(Value, "chat_id", translate("Chat ID"))
o.placeholder = "123456789"
o.description = translate("Kirim pesan ke @userinfobot untuk cek Chat ID kamu")
o:depends("enabled","1")
o = s:option(Flag,  "notify_on_check", translate("Notif Setiap Kali Cek"))
o.default = "1"
o:depends("enabled","1")

-- Jadwal Telegram
o = s:option(Flag,  "schedule_enabled", translate("Kirim Jadwal Otomatis"))
o.default = "0"
o.description = translate("Kirim ringkasan tagihan ke Telegram sesuai jadwal")
o:depends("enabled","1")

o = s:option(ListValue, "schedule_type", translate("Tipe Jadwal"))
o:value("daily",  "Setiap Hari")
o:value("weekly", "Mingguan (pilih hari)")
o.default = "daily"
o:depends("schedule_enabled","1")

o = s:option(ListValue, "schedule_hour", translate("Jam Pengiriman"))
for h=0,23 do
    o:value(tostring(h), string.format("%02d:00", h))
end
o.default = "8"
o:depends("schedule_enabled","1")

o = s:option(ListValue, "schedule_minute", translate("Menit"))
o:value("0",  ":00")
o:value("15", ":15")
o:value("30", ":30")
o:value("45", ":45")
o.default = "0"
o:depends("schedule_enabled","1")

o = s:option(ListValue, "schedule_day", translate("Hari (khusus mingguan)"))
o:value("0", "Minggu")
o:value("1", "Senin")
o:value("2", "Selasa")
o:value("3", "Rabu")
o:value("4", "Kamis")
o:value("5", "Jumat")
o:value("6", "Sabtu")
o.default = "1"
o:depends("schedule_type","weekly")

-- Auto Check
s = m:section(NamedSection, "settings", "tagihan", translate("Pengecekan Otomatis"))
s.anonymous = false
o = s:option(Flag,     "auto_check", translate("Aktifkan Cek Otomatis"))
o.default = "1"; o.rmempty = false
o = s:option(ListValue,"interval", translate("Interval Pengecekan"))
o:value("1","Setiap 1 Jam"); o:value("3","Setiap 3 Jam")
o:value("6","Setiap 6 Jam"); o:value("12","Setiap 12 Jam")
o:value("24","Setiap 24 Jam")
o.default = "6"

return m
