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
    local data = { pln={}, pdam={}, wifi={} }

    data.pln.enabled     = uci:get("tagihan","pln","enabled")     or "0"
    data.pln.nama        = uci:get("tagihan","pln","nama")        or ""
    data.pln.tagihan     = uci:get("tagihan","pln","tagihan")     or "0"
    data.pln.periode     = uci:get("tagihan","pln","periode")     or ""
    data.pln.daya        = uci:get("tagihan","pln","daya")        or ""
    data.pln.tarif       = uci:get("tagihan","pln","tarif")       or ""
    data.pln.status      = uci:get("tagihan","pln","status")      or "belum_dicek"
    data.pln.idpel       = uci:get("tagihan","pln","idpel")       or ""

    data.pdam.enabled         = uci:get("tagihan","pdam","enabled")         or "0"
    data.pdam.nama            = uci:get("tagihan","pdam","nama")            or ""
    data.pdam.tagihan         = uci:get("tagihan","pdam","tagihan")         or "0"
    data.pdam.periode         = uci:get("tagihan","pdam","periode")         or ""
    data.pdam.pemakaian       = uci:get("tagihan","pdam","pemakaian")       or ""
    data.pdam.status          = uci:get("tagihan","pdam","status")          or "belum_dicek"
    data.pdam.nomor_pelanggan = uci:get("tagihan","pdam","nomor_pelanggan") or ""
    data.pdam.bayar_status    = uci:get("tagihan","pdam","bayar_status")    or ""

    data.wifi.enabled      = uci:get("tagihan","wifi","enabled")      or "0"
    data.wifi.nama_paket   = uci:get("tagihan","wifi","nama_paket")   or ""
    data.wifi.tagihan      = uci:get("tagihan","wifi","tagihan")      or "0"
    data.wifi.jatuh_tempo  = uci:get("tagihan","wifi","jatuh_tempo")  or ""
    data.wifi.status       = uci:get("tagihan","wifi","status")       or "belum_dicek"

    luci.template.render("tagihan/dashboard", { data = data })
end

function action_log()
    luci.template.render("tagihan/log", {})
end

function action_getlog()
    local http = require "luci.http"
    http.prepare_content("text/plain")
    local f = io.open("/tmp/tagihan-last.log", "r")
    if f then http.write(f:read("*a")); f:close()
    else http.write("(log kosong)") end
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
        pln  = {status=uci:get("tagihan","pln","status") or "belum_dicek",
                tagihan=uci:get("tagihan","pln","tagihan") or "0"},
        pdam = {status=uci:get("tagihan","pdam","status") or "belum_dicek",
                tagihan=uci:get("tagihan","pdam","tagihan") or "0"},
        wifi = {status=uci:get("tagihan","wifi","status") or "belum_dicek",
                tagihan=uci:get("tagihan","wifi","tagihan") or "0"},
    }))
end
