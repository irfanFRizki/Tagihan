-- /usr/lib/lua/luci/controller/tagihan.lua
module("luci.controller.tagihan", package.seeall)

function index()
    -- ✅ FIX: tidak pakai nixio guard agar menu selalu muncul
    -- (config dibuat oleh postinst / uci-defaults)
    local page
    page = entry(
        {"admin", "services", "tagihan"},
        alias("admin", "services", "tagihan", "dashboard"),
        _("Tagihan Bot"), 60
    )
    page.dependent   = false
    page.acl_depends = { "luci-app-tagihan" }

    entry({"admin", "services", "tagihan", "dashboard"},
        call("action_dashboard"),
        _("Dashboard"), 10).leaf = true

    entry({"admin", "services", "tagihan", "settings"},
        cbi("tagihan/settings"),
        _("Pengaturan"), 20).leaf = true

    entry({"admin", "services", "tagihan", "refresh"},
        call("action_refresh")).leaf = true

    entry({"admin", "services", "tagihan", "status"},
        call("action_status")).leaf = true
end

function action_dashboard()
    local uci  = require "luci.model.uci".cursor()
    local data = { pln = {}, pdam = {}, wifi = {} }

    data.pln.enabled     = uci:get("tagihan", "pln",  "enabled")          or "0"
    data.pln.nama        = uci:get("tagihan", "pln",  "nama")             or ""
    data.pln.tagihan     = uci:get("tagihan", "pln",  "tagihan")          or "0"
    data.pln.periode     = uci:get("tagihan", "pln",  "periode")          or ""
    data.pln.daya        = uci:get("tagihan", "pln",  "daya")             or ""
    data.pln.tarif       = uci:get("tagihan", "pln",  "tarif")            or ""
    data.pln.status      = uci:get("tagihan", "pln",  "status")           or "belum_dicek"
    data.pln.last_update = uci:get("tagihan", "pln",  "last_update")      or ""
    data.pln.idpel       = uci:get("tagihan", "pln",  "idpel")            or ""

    data.pdam.enabled         = uci:get("tagihan", "pdam", "enabled")         or "0"
    data.pdam.nama            = uci:get("tagihan", "pdam", "nama")            or ""
    data.pdam.tagihan         = uci:get("tagihan", "pdam", "tagihan")         or "0"
    data.pdam.periode         = uci:get("tagihan", "pdam", "periode")         or ""
    data.pdam.pemakaian       = uci:get("tagihan", "pdam", "pemakaian")       or ""
    data.pdam.status          = uci:get("tagihan", "pdam", "status")          or "belum_dicek"
    data.pdam.last_update     = uci:get("tagihan", "pdam", "last_update")     or ""
    data.pdam.nomor_pelanggan = uci:get("tagihan", "pdam", "nomor_pelanggan") or ""

    data.wifi.enabled      = uci:get("tagihan", "wifi", "enabled")      or "0"
    data.wifi.nama_paket   = uci:get("tagihan", "wifi", "nama_paket")   or ""
    data.wifi.tagihan      = uci:get("tagihan", "wifi", "tagihan")      or "0"
    data.wifi.jatuh_tempo  = uci:get("tagihan", "wifi", "jatuh_tempo")  or ""
    data.wifi.status       = uci:get("tagihan", "wifi", "status")       or "belum_dicek"
    data.wifi.last_update  = uci:get("tagihan", "wifi", "last_update")  or ""

    luci.template.render("tagihan/dashboard", { data = data })
end

function action_refresh()
    local http   = require "luci.http"
    local target = http.formvalue("target") or "all"
    os.execute("/usr/bin/tagihan-check " .. target .. " > /tmp/tagihan-last.log 2>&1 &")
    http.prepare_content("application/json")
    http.write('{"status":"running","target":"' .. target .. '"}')
end

function action_status()
    local http = require "luci.http"
    local uci  = require "luci.model.uci".cursor()
    local json = require "luci.jsonc"
    local result = {
        pln  = {
            status      = uci:get("tagihan","pln","status")      or "belum_dicek",
            nama        = uci:get("tagihan","pln","nama")        or "",
            tagihan     = uci:get("tagihan","pln","tagihan")     or "0",
            periode     = uci:get("tagihan","pln","periode")     or "",
            last_update = uci:get("tagihan","pln","last_update") or "",
        },
        pdam = {
            status      = uci:get("tagihan","pdam","status")      or "belum_dicek",
            nama        = uci:get("tagihan","pdam","nama")        or "",
            tagihan     = uci:get("tagihan","pdam","tagihan")     or "0",
            last_update = uci:get("tagihan","pdam","last_update") or "",
        },
        wifi = {
            status      = uci:get("tagihan","wifi","status")      or "belum_dicek",
            nama_paket  = uci:get("tagihan","wifi","nama_paket")  or "",
            tagihan     = uci:get("tagihan","wifi","tagihan")     or "0",
            last_update = uci:get("tagihan","wifi","last_update") or "",
        }
    }
    http.prepare_content("application/json")
    http.write(json.stringify(result))
end
