module("luci.controller.tagihan", package.seeall)

function index()
    local page
    page = entry({"admin","services","tagihan"},
        alias("admin","services","tagihan","dashboard"),
        _("Tagihan Bot"), 60)
    page.dependent   = false
    page.acl_depends = { "luci-app-tagihan" }

    entry({"admin","services","tagihan","dashboard"},
        call("action_dashboard"), _("Dashboard"), 10).leaf = true
    entry({"admin","services","tagihan","settings"},
        cbi("tagihan/settings"), _("Pengaturan"), 20).leaf = true
    entry({"admin","services","tagihan","log"},
        call("action_log"), _("Log"), 30).leaf = true
    entry({"admin","services","tagihan","refresh"},
        call("action_refresh")).leaf = true
    entry({"admin","services","tagihan","status"},
        call("action_status")).leaf = true
    entry({"admin","services","tagihan","getlog"},
        call("action_getlog")).leaf = true
end

function action_dashboard()
    local uci  = require "luci.model.uci".cursor()
    local data = { pdam={}, wifi={} }

    data.pdam.enabled         = uci:get("tagihan","pdam","enabled")         or "0"
    data.pdam.nama            = uci:get("tagihan","pdam","nama")            or ""
    data.pdam.tagihan         = uci:get("tagihan","pdam","tagihan")         or "0"
    data.pdam.tagihan_str     = uci:get("tagihan","pdam","tagihan_str")     or ""
    data.pdam.periode         = uci:get("tagihan","pdam","periode")         or ""
    data.pdam.pemakaian       = uci:get("tagihan","pdam","pemakaian")       or ""
    data.pdam.bayar_status    = uci:get("tagihan","pdam","bayar_status")    or ""
    data.pdam.golongan        = uci:get("tagihan","pdam","golongan")        or ""
    data.pdam.jatuh_tempo     = uci:get("tagihan","pdam","jatuh_tempo")     or ""
    data.pdam.status          = uci:get("tagihan","pdam","status")          or "belum_dicek"
    data.pdam.nomor_pelanggan = uci:get("tagihan","pdam","nomor_pelanggan") or ""
    data.pdam.last_check_time = uci:get("tagihan","pdam","last_check_time") or ""

    data.wifi.enabled         = uci:get("tagihan","wifi","enabled")         or "0"
    data.wifi.nama            = uci:get("tagihan","wifi","nama")            or ""
    data.wifi.id_pelanggan    = uci:get("tagihan","wifi","id_pelanggan")    or ""
    data.wifi.tagihan         = uci:get("tagihan","wifi","tagihan")         or "0"
    data.wifi.tagihan_str     = uci:get("tagihan","wifi","tagihan_str")     or "Rp 0"
    data.wifi.invoice         = uci:get("tagihan","wifi","invoice")         or ""
    data.wifi.jatuh_tempo     = uci:get("tagihan","wifi","jatuh_tempo")     or ""
    data.wifi.status_bayar    = uci:get("tagihan","wifi","status_bayar")    or ""
    data.wifi.status          = uci:get("tagihan","wifi","status")          or "belum_dicek"
    data.wifi.last_check_time = uci:get("tagihan","wifi","last_check_time") or ""

    luci.template.render("tagihan/dashboard", { data = data })
end

function action_log()
    luci.template.render("tagihan/log", {})
end

function action_getlog()
    local http = require "luci.http"
    http.prepare_content("text/plain")
    local f = io.open("/tmp/tagihan-last.log","r")
    if f then http.write(f:read("*a")); f:close()
    else http.write("(log kosong - belum ada pengecekan)") end
end

function action_refresh()
    local http   = require "luci.http"
    local target = http.formvalue("target") or "all"
    os.execute("/usr/bin/tagihan-check "..target.." > /tmp/tagihan-last.log 2>&1 &")
    http.prepare_content("application/json")
    http.write('{"status":"running","target":"'..target..'"}')
end

function action_status()
    local http = require "luci.http"
    local uci  = require "luci.model.uci".cursor()
    local json = require "luci.jsonc"
    http.prepare_content("application/json")
    http.write(json.stringify({
        pdam = {status = uci:get("tagihan","pdam","status") or "belum_dicek"},
        wifi = {status = uci:get("tagihan","wifi","status") or "belum_dicek"},
    }))
end
