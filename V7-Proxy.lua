-- Script by V7-Factory

local proxy = {}
local command = {}
local PlayerList = {}
local LogSpin = {}

proxy.dev = "V7"
proxy.name = "V7-Factory"
proxy.version = "BETA"
proxy.support = "undefined"

local version = "BETA"
local rfspin = true
local reme = true
local qeme = false
local realfakes = "1"
local remeg = "1"
local qemeg = "0"
local showtext = false
local pendingFakeSpins = {}
local lastLogKey = nil
local lastLogTime = 0
local lastFakeLogKey = nil
local lastFakeLogTime = 0
local pendingShowText = {}
local SHOWTEXT_GUARD_SECONDS = 2

local data = {}
local Amount = 0
local Tax = 0
local Bet = 0
local PX1, PY1 = nil, nil
local PX2, PY2 = nil, nil

command.var = {}
command.var.taptp = false
command.var.rfspin = false

local function SleepS(sec)
    sleep(sec * 1000)
end

local loginp = [[
set_border_color|112,86,191,255
set_bg_color|43,34,74,200
set_default_color|`0
add_label_with_icon|big|`cV7-Proxy          ``Information|left|9474|
add_smalltext|             Version `2BETA|
add_spacer|small|
add_label_with_icon|small|Proxy made by `2@kevin.sinaga|left|12436|
add_spacer|small|
add_label_with_icon|big|`2Command :|left|32|
add_textbox|`^/proxy ``(Show all commands)|
add_spacer|small|
add_label_with_icon|big|`2Update Logs :|left|5016|
add_textbox|- Improved UI|
add_textbox|- Added `^/showtext ``(Show text from several overlays)|
add_textbox|- Added `^/buybgl ``<amount> (Buy `eBGL ``from store)|
add_textbox|- Added `^/dq ``(Daily quest)|
add_textbox|- Added `^/de ``<amount> (Drop `2(C) Elite Volt Lock``)|
add_textbox|- Added `^/dr ``<amount> (Drop `4(C) Red Gem Lock``)|
add_textbox|- Added `^/spin ``(Show spin menu)|
add_textbox|- Added `^/time ``(Show your region time & date)|
add_spacer|small|
add_label_with_icon|small|`4DO NOT RESELL THIS SCRIPT!|left|1432|
add_spacer|small|
end_dialog|loginpend|Close||
add_quick_exit|
]]

local proxyDialog = [[
set_border_color|112,86,191,255
set_bg_color|43,34,74,200
set_default_color|`0
add_label_with_icon|big|`cV7-Proxy    ``Commands    |left|9474|
add_smalltext|             Version `2BETA|
add_spacer|small|
add_label_with_icon|small|Proxy made by `2@kevin.sinaga|left|12436|
add_spacer|small|
add_label_with_icon|big|`2Information :|left|32|
add_textbox|`^/gazette ``(Show proxy information)|
add_spacer|small|
add_label_with_icon|big|`2Fast Drop :|left|13810|
add_textbox|`^/de ``<amount> (Drop `2(C) Elite Volt Lock``)|
add_textbox|`^/dr ``<amount> (Drop `4(C) Red Gem Lock``)|
add_textbox|`^/db ``<amount> (Drop `eBlue Gem Lock``)|
add_textbox|`^/dd ``<amount> (Drop `1Diamond Lock``)|
add_textbox|`^/dw ``<amount> (Drop `9World Lock``)|
add_textbox|`^/cd ``<amount> (Custom drop)|
add_textbox|`^/daw ``(Drop all locks)|
add_spacer|small|
add_label_with_icon|big|`2Hosting Helper :|left|758|
add_textbox|`^/pos ``<1-2> (Set take & drop bets position)|
add_textbox|`^/tax ``<amount> (Set tax)|
add_textbox|`^/bet ``<amount> (Set bet)|
add_textbox|`^/take ``(Take bets from position 1 & 2)|
add_textbox|`^/win ``<1-2> (Drop bets to winner)|
add_spacer|small|
add_label_with_icon|big|`2Gamble Helper :|left|32|
add_textbox|`^/balance ``(Show your balance)|
add_textbox|`^/spin ``(Show spin menu)|
add_textbox|`^/slog ``(Show spin history)|
add_textbox|`^/showtext ``(Show text from several overlays)|
add_textbox|`^/time ``(Show your region time & date)|
add_textbox|`^/ce ``(Compress 100 `4(C) Red Gem Lock``)|
add_textbox|`^/be ``(Shatter 1 `2(C) Elite Volt Lock``)|
add_textbox|`^/cr ``(Compress 100 `eBlue Gem Lock``)|
add_textbox|`^/br ``(Shatter 1 `4(C) Red Gem Lock``)|
add_textbox|`^/cb ``(Compress 100 `1Diamond Lock``)|
add_textbox|`^/buybgl ``<amount> (Buy `eBGL ``from store)|
add_textbox|`^/dq ``(Daily quest)|
add_spacer|small|
add_label_with_icon|small|`4DO NOT RESELL THIS SCRIPT!|left|1432|
add_spacer|small|
end_dialog|bye|Close|
add_quick_exit|
]]

local function dext()
    return [[
set_border_color|112,86,191,255
set_bg_color|43,34,74,200
set_default_color|`0
add_label_with_icon|big|Spin Cheats|left|758|
text_scaling_string|iprogramtext
add_spacer|small|
add_checkbox|realfakespin|`2REAL``/`4FAKE ``spin detector|]] .. tostring(realfakes) .. [[|
add_checkbox|gamereme|`^REME ``spin counter|]] .. tostring(remeg) .. [[|
add_checkbox|gameqeme|`9QEME ``spin counter|]] .. tostring(qemeg) .. [[|
add_spacer|small|
end_dialog|proxywrenchend|Close|Update|
add_quick_exit|
]]
end

local function DropItem(id, count)
    count = tonumber(count)
    if not count or count <= 0 then
        return
    end

    sendPacket(2, "action|drop_item\nitemID|" .. id .. "\n")
    sendPacket(
        2,
        "action|dialog_return\ndialog_name|drop_item\nitemID|" ..
        id .. "|\ncount|" .. count .. "\n"
    )
end

local function checkitm(id)
    for _, inv in pairs(getInventory()) do
        if inv.id == id then
            return inv.amount
        end
    end
    return 0
end

local function wear(id)
    sendPacketRaw(false, {
        type = 10,
        value = id
    })
end

local function ovlay(str)
    str = tostring(str)
    sendVariant({
        [0] = "OnTextOverlay",
        [1] = str
    })
    return str
end

local function normalizeShowText(str)
    str = tostring(str or "")
    str = str:gsub("`.", "")
    str = str:gsub("\r", " "):gsub("\n", " ")
    str = str:gsub("%s+", " ")
    str = str:match("^%s*(.-)%s*$") or ""
    return str
end

local function showOverlayText(str)
    if showtext then
        local text = tostring(str)
        local key = normalizeShowText(text)

        if key ~= "" then
            pendingShowText[key] = os.clock()
        end

        sendPacket(2, "action|input\n|text|" .. text)
    end
end

local function ovlayAndShow(str)
    local text = ovlay(str)
    showOverlayText(text)
    return text
end

local function tol(txt)
    logToConsole("`b[`cV7-Proxy``] `o" .. tostring(txt))
end

local function AddOrUpdatePlayer(name, netid)
    netid = tonumber(netid)

    if not netid then
        return
    end

    PlayerList[netid] = {
        name = name or tostring(netid),
        netid = netid
    }
end

local function getLocalPlayerSafe()
    if not getWorld() then
        return nil
    end

    local ok, lp = pcall(getLocal)
    if not ok or not lp then
        return nil
    end

    return lp
end

local function getLocalNetID()
    local lp = getLocalPlayerSafe()
    if not lp then
        return nil
    end
    return tonumber(lp.netId or lp.netid or lp.netID)
end

local function GetName(netid)
    netid = tonumber(netid)

    if not netid then
        return "Unknown"
    end

    if PlayerList[netid] and PlayerList[netid].name then
        return PlayerList[netid].name
    end

    for _, player in pairs(PlayerList) do
        if tonumber(player.netid) == netid and player.name then
            return player.name
        end
    end

    local localNetID = getLocalNetID()
    local lp = getLocalPlayerSafe()
    if localNetID and netid == localNetID and lp then
        return lp.name or lp.Name or tostring(netid)
    end

    return tostring(netid)
end

local function multiboxChecker(value)
    return value and "1" or "0"
end

local function remefunc(number)
    number = tonumber(number) or 0

    if number == 19 or number == 28 or number == 0 then
        return 0
    end

    local num1 = math.floor(number / 10)
    local num2 = number % 10

    return tonumber(string.sub(tostring(num1 + num2), -1)) or 0
end

local function qemefunc(number)
    number = tonumber(number) or 0

    if number >= 10 then
        return tonumber(string.sub(tostring(number), -1)) or 0
    end

    return number
end

local function getGame(num)
    num = tonumber(num) or 0

    if reme and not qeme then
        return " `^REME `6" .. remefunc(num)
    elseif not reme and qeme then
        return " `9QEME `6" .. qemefunc(num)
    elseif reme and qeme then
        return " `^REME `6" .. remefunc(num) ..
            " `0/ `9QEME `6" .. qemefunc(num)
    end

    return ""
end

local function Data()
    Amount = 0

    for _, item in pairs(data) do
        if item.id == 14860 then
            Amount = Amount + item.count * 100000000
        elseif item.id == 9782 then
            Amount = Amount + item.count * 1000000
        elseif item.id == 7188 then
            Amount = Amount + item.count * 10000
        elseif item.id == 1796 then
            Amount = Amount + item.count * 100
        elseif item.id == 242 then
            Amount = Amount + item.count
        end
    end

    data = {}
end

local function isWorldReady()
    local world = getWorld()
    return world ~= nil
end

local function getPlayerPosition()
    if not isWorldReady() then
        return nil, nil, "World is not loaded yet."
    end

    local lp = getLocalPlayerSafe()
    if not lp then
        return nil, nil, "Local player is not detected."
    end

    -- Only access NetAvatar.pos after getWorld() confirms a valid world.
    local pos = lp.pos
    if not pos or pos.x == nil or pos.y == nil then
        return nil, nil, "Player position is not ready yet."
    end

    return math.floor(pos.x / 32), math.floor(pos.y / 32)
end

local function getObjectPosition(obj)
    if not obj then
        return nil, nil
    end

    local x, y

    if obj.pos and obj.pos.x ~= nil and obj.pos.y ~= nil then
        x = obj.pos.x
        y = obj.pos.y
    elseif obj.x ~= nil and obj.y ~= nil then
        x = obj.x
        y = obj.y
    elseif obj.position and obj.position.x ~= nil and obj.position.y ~= nil then
        x = obj.position.x
        y = obj.position.y
    end

    if x == nil or y == nil then
        return nil, nil
    end

    return x, y
end

local function getWinPosition(position)
    if position == 1 then
        if not PX1 or not PY1 then
            return nil, nil
        end
        return PX1, PY1
    end

    if position == 2 then
        if not PX2 or not PY2 then
            return nil, nil
        end
        return PX2 + 2, PY2
    end

    return nil, nil
end

local function collect()
    data = {}

    if not isWorldReady() then
        tol("`4World is not loaded. Collect cancelled.")
        return false
    end

    if not PX1 or not PY1 or not PX2 or not PY2 then
        tol("`4Please set both positions first with /pos 1 and /pos 2.")
        return false
    end

    local worldObjects = getWorldObject()

    if not worldObjects then
        tol("`4World objects are not detected.")
        return false
    end

    local tiles = {
        {x = PX1, y = PY1},
        {x = PX2, y = PY2}
    }

    local collected = {}
    local found = false

    for _, obj in pairs(worldObjects) do
        local objX, objY = getObjectPosition(obj)

        if objX and objY and obj.oid then
            local tx = math.floor(objX / 32)
            local ty = math.floor(objY / 32)

            for _, tile in pairs(tiles) do
                if tx == tile.x and ty == tile.y and not collected[obj.oid] then
                    collected[obj.oid] = true
                    found = true

                    sendPacketRaw(false, {
                        type = 11,
                        value = obj.oid,
                        x = objX,
                        y = objY
                    })

                    table.insert(data, {
                        id = obj.id,
                        count = obj.amount
                    })

                    break
                end
            end
        end
    end

    Data()

    return found
end

local function logspin()
    local dialogSpin = {}

    for _, spin in pairs(LogSpin) do
        table.insert(dialogSpin, spin.spin)
    end

    local world = getWorld()
    local worldName = world and world.name or "Unknown"

    sendVariant({
        [0] = "OnDialogRequest",
        [1] =
            "set_border_color|112,86,191,255|\n" ..
            "set_bg_color|43,34,74,200|\n" ..
            "set_default_color|`0\n" ..
            "add_label_with_icon|big|Spin Logs|left|1436|\n" ..
            "add_spacer|small|\n" ..
            "add_textbox|Current world : `c" .. worldName .. "|left|\n" ..
            "add_smalltext|Click the wheel icon to filter the spins|\n" ..
            table.concat(dialogSpin) ..
            "\nadd_spacer|small|\n" ..
            "add_quick_exit|||\n" ..
            "end_dialog|world_spin|Close||"
    }, -1, 200)
end

local function filterspin(id)
    id = tonumber(id)

    if not id then
        return
    end

    local localNetID = getLocalNetID()
    if localNetID and id == localNetID then
        for _, log in pairs(LogSpin) do
            if tonumber(log.netid) == 0 and
               tostring(log.spins or ""):find("%[`4FAKE", 1, true) then
                log.netid = localNetID
            end
        end
    end

    local filterLog = {}

    for _, log in pairs(LogSpin) do
        if log.netid == id then
            table.insert(
                filterLog,
                "\nadd_label_with_icon|small|" ..
                log.spin ..
                "|left|758|\n"
            )
        end
    end

    sendVariant({
        [0] = "OnDialogRequest",
        [1] =
            "set_border_color|112,86,191,255|\n" ..
            "set_bg_color|43,34,74,200|\n" ..
            "set_default_color|`0\n" ..
            "add_label_with_icon|big|" ..
            GetName(id) ..
            "'s ``Spin Logs|left|1436|\n" ..
            "add_spacer|small|\n" ..
            table.concat(filterLog) ..
            "|\nadd_spacer|small|\n" ..
            "add_quick_exit|||\n" ..
            "add_button|backtospin|Back||"
    }, -1, 200)
end

local function convertLocks(value)
    value = math.floor(tonumber(value) or 0)

    local result = {
        evl = math.floor(value / 100000000)
    }

    value = value - result.evl * 100000000

    result.rgl = math.floor(value / 1000000)
    value = value - result.rgl * 1000000

    result.bgl = math.floor(value / 10000)
    value = value - result.bgl * 10000

    result.dl = math.floor(value / 100)
    result.wl = value % 100

    return result
end

local function dropLocks(lock)
    if lock.evl > 0 then
        DropItem(14860, lock.evl)
    end

    if lock.rgl > 0 then
        DropItem(9782, lock.rgl)
    end

    if lock.bgl > 0 then
        DropItem(7188, lock.bgl)
    end

    if lock.dl > 0 then
        DropItem(1796, lock.dl)
    end

    if lock.wl > 0 then
        DropItem(242, lock.wl)
    end
end

local function lockText(lock, overlay)
    local text = ""

    if lock.evl > 0 then
        text = text .. lock.evl .. " `2(C) Elite Volt Lock"
        if overlay then text = text .. "`9." end
    end

    if lock.rgl > 0 then
        text = text .. " `c" .. lock.rgl .. " `4(C) Red Gem Lock"
        if overlay then text = text .. "`9." end
    end

    if lock.bgl > 0 then
        text = text .. " `c" .. lock.bgl .. " `eBlue Gem Lock"
        if overlay then text = text .. "`9." end
    end

    if lock.dl > 0 then
        text = text .. " `c" .. lock.dl .. " `1Diamond Lock"
        if overlay then text = text .. "`9." end
    end

    if lock.wl > 0 then
        text = text .. " `c" .. lock.wl .. " `9World Lock"
        if overlay then text = text .. "`9." end
    end

    return text
end

local function ensureLocks(lock)
    if checkitm(242) < lock.wl then
        wear(1796)
        SleepS(0.15)
    end

    if checkitm(1796) < lock.dl then
        wear(7188)
        SleepS(0.15)
    end

    if checkitm(7188) < lock.bgl then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|ml_lock_2\n\n"
        )
        SleepS(0.15)
    end

    if checkitm(9782) < lock.rgl then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|el_lock_2\n\n"
        )
        SleepS(0.15)
    end
end

local function isPlayerChatConsoleMessage(text)
    local raw = tostring(text or "")
    local clean = raw:gsub("`.", "")

    -- Chat player yang kembali sebagai OnConsoleMessage biasanya membawa
    -- wrapper/prefix nama player. Pesan seperti ini tidak boleh diproses
    -- sebagai Collected, karena /showtext dari player lain bisa membuat
    -- ping-pong spam antar script.
    if raw:find("CP:_PL:0_OID:_player_chat=", 1, true) then
        return true
    end

    if raw:find("CP:_PL:0_OID:_CT:", 1, true) then
        return true
    end

    if clean:match("^%s*<[^>]+>%s+") then
        return true
    end

    return false
end

local function handleConsoleMessage(text)
    if not text then
        return false
    end

    local rawText = tostring(text)
    local clean = rawText:gsub("`.", "")
    local normalizedClean = normalizeShowText(clean)
    local now = os.clock()

    -- Anti-loop / anti-spam: text yang baru dikirim oleh /showtext bisa
    -- kembali sebagai OnConsoleMessage atau player chat. Jangan proses ulang
    -- text tersebut sebagai notifikasi Collected.
    for key, sentAt in pairs(pendingShowText) do
        if now - sentAt > SHOWTEXT_GUARD_SECONDS then
            pendingShowText[key] = nil
        elseif key ~= "" and normalizedClean:find(key, 1, true) then
            -- Jangan langsung hapus marker. Dalam waktu guard, echo yang
            -- sama bisa datang lebih dari sekali. Marker tetap hidup sampai
            -- timeout agar tidak lolos pada echo berikutnya.
            return true
        end
    end

    -- Penting: jika pesan berasal dari chat player, jangan jalankan seluruh
    -- detector Collected. Ini mencegah dua atau lebih player yang sama-sama
    -- memakai /showtext saling memantulkan text Collected tanpa henti.
    if isPlayerChatConsoleMessage(rawText) then
        return false
    end

    if clean:find("You collected") and clean:find("(%d+)") then
        if checkitm(9782) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|el_lock_1\n\n"
            )
        end

        if checkitm(7188) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|ml_lock_1\n\n"
            )
        end

        if checkitm(1796) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|chc2_2_1\n\n"
            )
        end

        if checkitm(242) > 0 then
            wear(242)
        end
    end

    if text:find("receives") and text:find("(%d+)") then
        if checkitm(9782) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|el_lock_1\n\n"
            )
        end

        if checkitm(7188) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|ml_lock_1\n\n"
            )
        end

        if checkitm(1796) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|chc2_2_1\n\n"
            )
        end

        if checkitm(242) > 0 then
            wear(242)
        end
    end

    if text:find("Received:") and
       text:find("(%d+)") and
       text:find("Blue Gem Lock") then

        if checkitm(9782) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|el_lock_1\n\n"
            )
        end

        if checkitm(7188) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|ml_lock_1\n\n"
            )
        end

        if checkitm(1796) > 0 then
            sendPacket(
                2,
                "action|dialog_return\ndialog_name|3898\n" ..
                "buttonClicked|chc2_2_1\n\n"
            )
        end

        if checkitm(242) > 0 then
            wear(242)
        end
    end

    local evl = clean:match("[Cc]ollected%s+(%d+)%s+%(%s*[Cc]%s*%)%s+Elite Volt Lock")
    if evl then
        tol("`9Collected `c" .. evl .. " `2(C) Elite Volt Lock`9.")
        ovlayAndShow("`9Collected `c" .. evl .. " `2(C) Elite Volt Lock")
        return true
    end

    local rgl = clean:match("[Cc]ollected%s+(%d+)%s+%(%s*[Cc]%s*%)%s+Red Gem Lock")
    if rgl then
        tol("`9Collected `c" .. rgl .. " `4(C) Red Gem Lock`9.")
        ovlayAndShow("`9Collected `c" .. rgl .. " `4(C) Red Gem Lock")

        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|el_lock_1\n\n"
        )

        return true
    end

    local bgl = clean:match("[Cc]ollected%s+(%d+)%s+Blue Gem Lock")
    if bgl then
        tol("`9Collected `c" .. bgl .. " `eBlue Gem Lock`9.")
        ovlayAndShow("`9Collected `c" .. bgl .. " `eBlue Gem Lock")

        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|ml_lock_1\n\n"
        )

        return true
    end

    local dl = clean:match("[Cc]ollected%s+(%d+)%s+Diamond Lock")
    if dl then
        tol("`9Collected `c" .. dl .. " `1Diamond Lock`9.")
        ovlayAndShow("`9Collected `c" .. dl .. " `1Diamond Lock")

        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|chc2_2_1\n\n"
        )

        return true
    end

    local wl = clean:match("[Cc]ollected%s+(%d+)%s+World Lock")
    if wl then
        tol("`9Collected `c" .. wl .. " ``World Lock.")
        ovlayAndShow("`9Collected `c" .. wl .. " ``World Lock")
        wear(242)
        return true
    end

    return false
end

local function cleanSpinText(text)
    return tostring(text or ""):gsub("`.", "")
end

local function trimText(text)
    return tostring(text or ""):match("^%s*(.-)%s*$") or ""
end

local function parseSpinNumber(text)
    local clean = cleanSpinText(text)
    if not clean:find("spun the wheel and got") then
        return nil, nil
    end

    local raw = clean:match("spun the wheel and got%s+(.+)")
    if not raw then
        return nil, nil
    end

    local num = raw:match("(%d+)")
    return tonumber(num), raw
end

local function getSpinPlayerName(text)
    local clean = cleanSpinText(text)
    local name = clean:match("%[([^%]]-)%s+spun the wheel and got")

    if name then
        return trimText(name)
    end

    local plain = clean:match("([^%[%]\n\r]+)%s+spun the wheel and got")
    if plain then
        plain = trimText(plain)
        plain = plain:match("([^>]+)$") or plain
        return trimText(plain)
    end

    return nil
end

-- Mengambil nama player dengan color-code asli, misalnya `9@Kev.
local function getSpinPlayerNameRaw(text)
    local raw = tostring(text or "")
    local name = raw:match("%[([^%]]-)%s+spun the wheel and got")

    if not name then
        local before = raw:match("^(.-)%s+spun the wheel and got")
        if before then
            before = before:gsub("^.*[=>]", "")
            name = before
        end
    end

    if not name then
        return nil
    end

    name = trimText(name)

    -- Pertahankan color prefix asli pada nama, contoh: `9@Kev `0 -> `9@Kev.
    local color, playerName = name:match("^(`%d)(@?.*)$")
    if color and playerName then
        playerName = playerName:gsub("%s*`%d+$", "")
        playerName = trimText(playerName)
        if playerName ~= "" then
            return color .. playerName
        end
    end

    name = name:gsub("%s*`%d+$", "")
    name = trimText(name)
    if name == "" then
        return nil
    end

    return name
end

local function extractSpinText(text)
    local raw = tostring(text or "")
    local clean = cleanSpinText(raw)

    local name, number = clean:match("%[([^%]]-)%s+spun the wheel and got%s+(%d+)")
    if not name or not number then
        return clean
    end

    local _, pos = raw:find("spun the wheel and got", 1, true)
    if not pos then
        return clean
    end

    local prefix = raw:sub(1, pos)
    local startPos = prefix:match("^.*()(%[)")
    if startPos then
        local candidate = raw:sub(startPos)
        if candidate:match("^%[.-spun the wheel and got") then
            return candidate
        end
    end

    return clean
end

local function getSpinLogText(text)
    local raw = trimText(text)
    if raw == "" then
        return raw
    end

    -- Buang wrapper packet, tetapi jangan mengubah format chat aslinya.
    raw = raw:gsub("^CP:_PL:0_OID:_player_chat=", "")
    raw = raw:gsub("^CP:_PL:0_OID:_CT:%[W%]_?%s*", "")
    raw = raw:gsub("^`6<.-`6>%s*", "")
    raw = trimText(raw)

    local spinPos = raw:find("spun the wheel and got", 1, true)
    if not spinPos then
        return raw
    end

    -- Jika input sudah memiliki [ ... ], pertahankan persis format tersebut.
    local before = raw:sub(1, spinPos - 1)
    local openPos = before:match("^.*()(%[)")
    if openPos then
        local candidate = trimText(raw:sub(openPos))
        if candidate:match("^%[.-spun the wheel and got") then
            return candidate
        end
    end

    -- Jika input tidak memiliki bracket, jangan menambahkannya.
    -- Contoh: `9@Kev `0spun the wheel and got `419``!
    return raw
end

local function buildFakeBubbleFromInput(input)
    local raw = tostring(input or "")
    local prefix, chat = raw:match("^(CP:_PL:0_OID:_player_chat=)(.*)$")

    if not chat then
        return nil, nil
    end

    if not chat:lower():find("spun the wheel and got", 1, true) then
        return nil, nil
    end

    local lp = getLocalPlayerSafe()
    local ownerName = getSpinPlayerNameRaw(chat) or (lp and (lp.name or lp.Name)) or getSpinPlayerName(chat) or "Unknown"
    ownerName = tostring(ownerName):gsub("`.", "")

    -- Input player_chat -> format OnTalkBubble yang diharapkan.
    local bubble = "CP:_PL:0_OID:_CT:[W]_ `6<`9" .. ownerName .. "`6> " .. chat
    return bubble, chat
end

local function buildFakeConsoleFromInput(input)
    local raw = tostring(input or "")
    local chat = raw:match("^CP:_PL:0_OID:_player_chat=(.*)$")

    if not chat then
        return nil, nil
    end

    if not chat:lower():find("spun the wheel and got", 1, true) then
        return nil, nil
    end

    local lp = getLocalPlayerSafe()
    local ownerName = getSpinPlayerNameRaw(chat) or (lp and (lp.name or lp.Name)) or getSpinPlayerName(chat) or "Unknown"
    ownerName = tostring(ownerName):gsub("`.", "")

    -- Primary FAKE output: emit a synthetic OnConsoleMessage.
    -- var[0] = OnConsoleMessage
    -- var[1] = <owner> <chat> [FAKE]
    local consoleText = "`6<`9" .. ownerName .. "`6> " .. chat .. " `0[`4FAKE``]"
    return consoleText, chat
end

local markFakeSpin

local function emitFakeConsoleFromInput(input)
    local consoleText, chat = buildFakeConsoleFromInput(input)
    if not consoleText then
        return false, nil
    end

    local lp = getLocalPlayerSafe()
    local localNetID = getLocalNetID() or 0
    markFakeSpin(chat)

    local ok, result = pcall(function()
        return sendVariant({
            [0] = "OnConsoleMessage",
            [1] = consoleText
        }, -1)
    end)

    if ok and result ~= false then
        return true, chat
    end

    return false, chat
end

markFakeSpin = function(text)
    local number = parseSpinNumber(text)
    if not number then
        return false
    end

    table.insert(pendingFakeSpins, {
        number = number,
        name = getSpinPlayerName(text),
        text = getSpinLogText(text),
        time = os.clock(),
        talkSeen = false,
        consoleSeen = false,
        logged = false
    })

    while #pendingFakeSpins > 10 do
        table.remove(pendingFakeSpins, 1)
    end

    return true
end

local function isPendingFakeSpin(text, eventType)
    local number = parseSpinNumber(text)
    if not number then
        return false
    end

    local name = getSpinPlayerName(text)
    local now = os.clock()

    for i = #pendingFakeSpins, 1, -1 do
        local fake = pendingFakeSpins[i]

        if now - fake.time > 5 then
            table.remove(pendingFakeSpins, i)
        elseif fake.number == number and
            (not fake.name or not name or fake.name == name) then

            if eventType == "talk" then
                fake.talkSeen = true
            elseif eventType == "console" then
                fake.consoleSeen = true
            end

            -- Jangan hapus marker di sini. shouldLogFakeSpin() masih
            -- membutuhkan marker yang sama untuk mencegah TalkBubble +
            -- ConsoleMessage membuat dua entry /slog. Marker akan dibersihkan
            -- otomatis setelah timeout.
            return true
        end
    end

    return false
end

local function shouldLogFakeSpin(text)
    local number = parseSpinNumber(text)
    local name = getSpinPlayerName(text) or ""
    local now = os.clock()

    -- Jika fake berasal dari input kita, TalkBubble dan ConsoleMessage
    -- merujuk ke pending fake yang sama. Log cukup dibuat satu kali.
    for i = #pendingFakeSpins, 1, -1 do
        local fake = pendingFakeSpins[i]

        if now - fake.time > 5 then
            table.remove(pendingFakeSpins, i)
        elseif fake.number == number and
            (not fake.name or not name or fake.name == name) then
            if fake.logged then
                return false
            end
            fake.logged = true
            return true
        end
    end

    -- Fallback untuk fake packet yang tidak punya pending marker.
    return true
end

local function addSpinLog(netid, status, text)
    local logText = getSpinLogText(text)
    local statusKey = tostring(status or ""):gsub("`.", "")
    local normalizedText = logText:gsub("`.", ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
    local number = parseSpinNumber(normalizedText)
    local name = getSpinPlayerName(normalizedText) or ""

    -- Untuk FAKE, gunakan isi spin canonical supaya perbedaan prefix CP,
    -- NetID, atau formatting tidak membuat TalkBubble + ConsoleMessage
    -- dianggap dua spin berbeda.
    local canonical = normalizedText:match("(%b[]%s+spun the wheel and got%s+%d+!?)")
    if not canonical then
        canonical = name .. "|" .. tostring(number or "")
    end

    local key = statusKey .. "|" .. canonical:lower()
    local now = os.clock()

    -- REAL dan FAKE sama-sama boleh datang dari TalkBubble + ConsoleMessage.
    -- Satu spin hanya boleh masuk /slog satu kali.
    if statusKey == "REAL" then
        if lastLogKey == key and now - lastLogTime <= 5 then
            return false
        end
        lastLogKey = key
        lastLogTime = now
    elseif statusKey == "FAKE" then
        if lastFakeLogKey == key and now - lastFakeLogTime <= 5 then
            return false
        end
        lastFakeLogKey = key
        lastFakeLogTime = now
    else
        if lastLogKey == key and now - lastLogTime <= 5 then
            return false
        end
        lastLogKey = key
        lastLogTime = now
    end

    table.insert(LogSpin, {
        spin =
            "\nadd_label_with_icon_button|small|[`2" ..
            os.date("%X") ..
            "``] [" .. status .. "``] " ..
            logText ..
            "|left|758|" ..
            tostring(netid or 0) ..
            "|\n",
        netid = netid,
        spins = "[" .. status .. "``] " .. logText
    })

    return true
end

local function getFakeBubbleText(text)
    local raw = tostring(text or "")
    local clean = cleanSpinText(raw)
    local spinText = getSpinLogText(raw)

    -- Jika yang diterima adalah wrapper CP:_PL:0_OID:_CT:[W]_ ...,
    -- ambil hanya bagian bubble chat-nya.
    local playerName, rest = spinText:match("^(%[[^%]]+%]%s*)(spun the wheel and got%s+%d+.*)$")
    if playerName and rest then
        return spinText
    end

    local bracket = clean:match("(%[[^%]]-%]%s+spun the wheel and got%s+%d+.*)")
    if bracket then
        return bracket
    end

    return spinText
end

local function handleSpin(var)
    if not var or var[0] ~= "OnTalkBubble" or not var[2] then
        return false
    end

    local text = tostring(var[2])

    -- Event OnTalkBubble yang sudah kita re-emit dengan [FAKE] adalah
    -- output final. Jangan proses ulang agar tidak recursive/duplikat.
    if text:find("%[`4FAKE``%]") then
        return false
    end

    local h = parseSpinNumber(text)
    if not h or not rfspin then
        return false
    end

    local netid = tonumber(var[1])

    -- Fake harus dicek SEBELUM duplicate check agar event OnTalkBubble
    -- tidak tertelan ketika OnConsoleMessage datang lebih dulu.
    local fakeDetected, fakeData = isPendingFakeSpin(text, "talk")
    local fake = text:find("OID:") ~= nil or fakeDetected

    if fake then
        local fakeText = (fakeData and fakeData.text) or getFakeBubbleText(text)
        local displayText = "[`4FAKE``] " .. fakeText

        if netid then
            local rawName = getSpinPlayerNameRaw(fakeText)
            if rawName then
                AddOrUpdatePlayer(rawName, netid)
            end
        end

        -- Fake TalkBubble: tetap kirim sebagai OnTalkBubble, hanya text-nya
        -- yang diberi prefix [FAKE].
        sendVariant({
            [0] = "OnTalkBubble",
            [1] = netid,
            [2] = displayText,
            [3] = 0
        }, -1)

        if shouldLogFakeSpin(fakeText) then
            addSpinLog(netid or ((function() local p = getLocalPlayerSafe(); return p and tonumber(p.netid) or 0 end)()), "`4FAKE", fakeText)
        end
        return true
    end

    local localPlayer = getLocalPlayerSafe()
    local localNetID = getLocalNetID()

    if netid then
        local playerName = getSpinPlayerName(text)

        if netid ~= localNetID then
            local rawName = getSpinPlayerNameRaw(text)
            AddOrUpdatePlayer(rawName or playerName or tostring(netid), netid)
        elseif localPlayer then
            local rawName = getSpinPlayerNameRaw(text)
            local cleanName = rawName or (localPlayer.name or localPlayer.Name or "Unknown")
            AddOrUpdatePlayer(cleanName, netid)
        end

        sendVariant({
            [0] = "OnNameChanged",
            [1] = GetName(netid) .. " `0[`2" .. h .. "``]"
        }, netid)
    end

    -- OnTalkBubble REAL = [REAL] di depan + REME/QEME di belakang.
    local displayText = "[`2REAL``] " .. text .. getGame(h)

    sendVariant({
        [0] = "OnTalkBubble",
        [1] = netid,
        [2] = displayText,
        [3] = 0
    }, -1)

    -- /slog hanya menyimpan text + status; REME/QEME tidak masuk history.
    addSpinLog(netid, "`2REAL", text)
    return true
end

AddHook("OnVarlist", "V7_Main", function(var)
    if var[0]:find("OnSpawn") and var[1]:find("name|") then
        local world = getWorld()
        local worldName = world and world.name or "Unknown"
        local name = var[1]:match("name|([^\n\r]+)")
        local lp = getLocalPlayerSafe()
        local localName = lp and (lp.name or lp.Name)

    if name and localName then
        local cleanName = name:gsub("`.", "")
        local cleanLocalName = localName:gsub("`.", "")

        if cleanName ~= cleanLocalName then
            tol("`5<`0" .. name .. " ``has joined this `c" .. worldName .. "``>")
            ovlay("`5<`0" .. name .. " ``has joined this " .. worldName .. "``>")
        end
    end
end

    if var[0] == "OnDialogRequest" then
        if var[1] and var[1]:find("3898") then
            return true
        end

        return false
    end

    if var[0] == "OnConsoleMessage" then
        local text = var[1] or ""

        if handleConsoleMessage(text) then
            return true
        end

        -- The decorated REAL console event is re-entered through this hook.
        -- Let that second-pass event through instead of processing it again.
        if text:find(" `0[`2REAL``]", 1, true) then
            return false
        end

        local h = parseSpinNumber(text)
        if h and rfspin then
            local localPlayer = getLocalPlayerSafe()
            local localNetID = getLocalNetID()
            local netid = tonumber(text:match("netid[=:|]%s*(%d+)")) or localNetID

            -- FAKE OnConsoleMessage: hanya tambahkan [FAKE] di belakang text.
            -- Untuk synthetic player_chat, prefix CP:_PL:0_OID:_... sudah
            -- dibuang sebelum event ini dikirim.
            local fakeDetected, fakeData = isPendingFakeSpin(text, "console")
            local fake = text:find("OID:") ~= nil or fakeDetected
            if fake then
                local fakeText = (fakeData and fakeData.text) or getFakeBubbleText(text)

                -- Jangan re-emit menjadi OnTalkBubble di sini. Event FAKE dari
                -- player_chat sekarang dipancarkan sebagai OnConsoleMessage.
                -- Dengan begitu var[0]/var[1] yang diterima hook persis sesuai
                -- format yang diinginkan.
                local displayText = tostring(text or "")
                displayText = displayText:gsub("%s*`0%[`4FAKE``%]", "")
                displayText = "`b[`cV7-Proxy``] `o" .. displayText .. " `0[`4FAKE``]"

                -- Modify the current FAKE console event itself.
                var[1] = displayText

                if localNetID then
                    local rawName = getSpinPlayerNameRaw(fakeText)
                    if rawName then
                        AddOrUpdatePlayer(rawName, localNetID)
                    elseif not PlayerList[localNetID] then
                        local lp = getLocalPlayerSafe()
                        AddOrUpdatePlayer((lp and (lp.name or lp.Name)) or tostring(localNetID), localNetID)
                    end
                end

                if shouldLogFakeSpin(fakeText) then
                    addSpinLog(localNetID or 0, "`4FAKE", fakeText)
                end

                -- Event synthetic FAKE sudah dimodifikasi di var[1].
                -- return false agar console tetap menerima event ini.
                return false
            end

            -- OnConsoleMessage REAL: watermark di kiri text spin + status di kanan.
            -- Modify event yang sama agar console tetap menerima pesan.
            local displayText = tostring(text or "")
            displayText = displayText:gsub("%s*`0%[%`?2REAL``%]", "")
            displayText = displayText:gsub("%s*`0%[`2REAL``%]", "")
            displayText = "`b[`cV7-Proxy``] `o" .. displayText .. " `0[`2REAL``]"
            var[1] = displayText

            if netid then
                local playerName = getSpinPlayerName(text)
                local rawName = getSpinPlayerNameRaw(text)
                playerName = rawName or playerName
                if not playerName and localPlayer then
                    playerName = localPlayer.name or "Unknown"
                end
                AddOrUpdatePlayer(playerName or tostring(netid), netid)
            end

            addSpinLog(netid, "`2REAL", text)

            -- Allow the modified event to reach the console.
            return false
        end

        return false
    end

    if var[0] == "OnTalkBubble" then
        return handleSpin(var)
    end

    return false
end)

AddHook("onTextPacket", "V7_Command", function(type, packet)
    local function inputText()
        return packet:match("action|input\n|text|(.-)$")
    end

    if packet:find("realfakespin|1") then
        rfspin = true
        realfakes = "1"
        ovlay("`9Spin menu is edited")
    elseif packet:find("realfakespin|0") then
        rfspin = false
        realfakes = "0"
        ovlay("`9Spin menu is edited")
    end

    if packet:find("gamereme|1") then
        reme = true
        remeg = "1"
    elseif packet:find("gamereme|0") then
        reme = false
        remeg = "0"
    end

    if packet:find("gameqeme|1") then
        qeme = true
        qemeg = "1"
    elseif packet:find("gameqeme|0") then
        qeme = false
        qemeg = "0"
    end

    local netid = packet:match("dialog_name|world_spin\nbuttonClicked|(%d+)")

    if netid then
        filterspin(tonumber(netid))
    end

    if packet:find("buttonClicked|backtospin") then
        logspin()
        return true
    end

    local input = inputText()

    if not input then
        return false
    end

    -- Fake spin dari player_chat: primary path adalah synthetic
    -- OnConsoleMessage. Packet input asli diblok agar tidak menghasilkan
    -- event player_chat yang tidak diinginkan. Handler OnConsoleMessage akan
    -- mengurus [FAKE] + /slog satu kali melalui pendingFakeSpins.
    if rfspin and input:lower():find("spun the wheel and got", 1, true) then
        local emitted, fakeChat = emitFakeConsoleFromInput(input)

        if emitted and fakeChat then
            return true
        end

        -- Fallback jika sendVariant(OnConsoleMessage) tidak tersedia/gagal:
        -- gunakan OnTalkBubble dengan format CP:_PL:0_OID:_CT:[W]_ sebagai
        -- jalur cadangan.
        local bubbleText, fallbackChat = buildFakeBubbleFromInput(input)
        if bubbleText and fallbackChat then
            local lp = getLocalPlayerSafe()
            local localNetID = getLocalNetID() or 0

            markFakeSpin(fallbackChat)

            sendVariant({
                [0] = "OnTalkBubble",
                [1] = localNetID,
                [2] = bubbleText .. " `0[`4FAKE``]",
                [3] = 0
            }, -1)

            local fakeText = getFakeBubbleText(fallbackChat)
            if shouldLogFakeSpin(fakeText) then
                addSpinLog(localNetID, "`4FAKE", fakeText)
            end

            return true
        end

        markFakeSpin(input)
        return false
    end

    local lower = input:lower()

    if lower == "/spin" then
        realfakes = multiboxChecker(rfspin)
        remeg = multiboxChecker(reme)
        qemeg = multiboxChecker(qeme)

        sendVariant({
            [0] = "OnDialogRequest",
            [1] = dext()
        }, -1, 100)

        logToConsole(" `6" .. input)
        return true
    end

    if lower == "/proxy" then
        sendVariant({
            [0] = "OnDialogRequest",
            [1] = proxyDialog
        })

        logToConsole(" `6" .. input)
        return true
    end

    if lower == "/gazette" then
        sendVariant({
            [0] = "OnDialogRequest",
            [1] = loginp
        })

        logToConsole(" `6" .. input)
        return true
    end

    if lower == "/showtext" then
        showtext = not showtext
        local status = showtext and "`9Show text `2enabled``." or "`9Show text `4disabled``."
        local status2 = showtext and "`9Show text `2enabled" or "`9Show text `4disabled"
        logToConsole(" `6" .. input)
        tol(status)
        ovlay(status2)
        return true
    end

    local dropCommands = {
        { command = "de", id = 14860, name = "`2(C) Elite Volt Lock`9", overlay = "`2(C) Elite Volt Lock" },
        { command = "dr", id = 9782, name = "`4(C) Red Gem Lock`9", overlay = "`4(C) Red Gem Lock" },
        { command = "db", id = 7188, name = "`eBlue Gem Lock`9", overlay = "`eBlue Gem Lock" },
        { command = "dd", id = 1796, name = "`1Diamond Lock`9", overlay = "`1Diamond Lock" },
        { command = "dw", id = 242, name = "`9World Lock", overlay = "`9World Lock" }
    }

    for _, drop in ipairs(dropCommands) do
        local amount = tonumber(lower:match("^/" .. drop.command .. "%s+(%d+)$"))

        if amount then
            if amount <= 0 then
                logToConsole(" `6" .. input)
                tol("`4Amount must be greater than `c0`4.")
                ovlayAndShow("`4Amount must be greater than `c0`4")
                return true
            end

            local available = checkitm(drop.id)

            if available < amount then
                logToConsole(" `6" .. input)
                tol("`4You don't have enough " .. drop.name .. "`4.")
                ovlayAndShow("`4You don't have enough " .. drop.overlay)
                return true
            end

            DropItem(drop.id, amount)
            logToConsole(" `6" .. input)
            tol("`9Dropped `c" .. amount .. " " .. drop.name .. "`9.")
            ovlayAndShow("`9Dropped `c" .. amount .. " " .. drop.overlay)
            return true
        end
    end
    local custom = lower:match("^/cd%s+(%d+)$")
    if custom then
        local lock = convertLocks(custom)

        ensureLocks(lock)
        SleepS(0.15)
        dropLocks(lock)

        local text = lockText(lock, true)
        local overlayText = lockText(lock, false)

        logToConsole(" `6" .. input)
        tol("`9Dropped `c" .. text)
        ovlayAndShow("`9Dropped `c" .. overlayText)
        return true
    end

    if lower == "/daw" then
        local lock = {
            evl = checkitm(14860),
            rgl = checkitm(9782),
            bgl = checkitm(7188),
            dl = checkitm(1796),
            wl = checkitm(242)
        }

        dropLocks(lock)

        local text = lockText(lock, true)
        local overlayText = lockText(lock, false)

        logToConsole(" `6" .. input)
        tol("`9Dropped `c" .. text)
        ovlayAndShow("`9Dropped `c" .. overlayText)
        return true
    end

    if lower == "/pos 1" then
        local x, y, err = getPlayerPosition()

        if not x or not y then
            tol("`4" .. (err or "Player position isn't detected."))
            ovlayAndShow("`4Player position isn't detected")
            return true
        end

        PX1 = x
        PY1 = y

        logToConsole(" `6" .. input)
        tol(
            "`9Set position 1 to (`c" ..
            PX1 .. "``, `c" .. PY1 .. "``)."
        )

        ovlayAndShow(
            "`9Set position 1 to (`c" ..
            PX1 .. "``, `c" .. PY1 .. "``)"
        )

        return true
    end

    if lower == "/pos 2" then
        local x, y, err = getPlayerPosition()

        if not x or not y then
            tol("`4" .. (err or "Player position isn't detected."))
            ovlayAndShow("`4Player position isn't detected")
            return true
        end

        PX2 = x
        PY2 = y

        logToConsole(" `6" .. input)
        tol(
            "`9Set position 2 to (`c" ..
            PX2 .. "``, `c" .. PY2 .. "``)."
        )

        ovlayAndShow(
            "`9Set position 2 to (`c" ..
            PX2 .. "``, `c" .. PY2 .. "``)"
        )

        return true
    end

    local taxValue = lower:match("^/tax%s+(%d+)$")
    if taxValue then
        Tax = tonumber(taxValue)

        logToConsole(" `6" .. input)
        tol("`9Set tax to : `c" .. Tax .. "%%``.")
        ovlayAndShow("`9Set tax to : `c" .. Tax .. "%")

        return true
    end

    local betValue = lower:match("^/bet%s+(%d+)$")
    if betValue then
        Bet = tonumber(betValue)

        logToConsole(" `6" .. input)
        tol("`9Set bet to : `c" .. Bet .. "``.")
        ovlayAndShow("`9Set bet to : `c" .. Bet)

        return true
    end

    if lower == "/take" then
        if not isWorldReady() then
            logToConsole(" `6" .. input)
            tol("`4World is not loaded. /take cancelled.")
            ovlayAndShow("`4World is not loaded")
            return true
        end

        if not PX1 or not PY1 or not PX2 or not PY2 then
            logToConsole(" `6" .. input)
            tol("`4Please set both positions first with /pos 1 and /pos 2.")
            ovlayAndShow("`4Set both positions first")
            return true
        end

        local success = collect()

        if not success then
            logToConsole(" `6" .. input)
            tol("`4No bet object found at position 1 or position 2.")
            ovlayAndShow("`4No bet object found")
            return true
        end

        if Amount <= 0 then
            logToConsole(" `6" .. input)
            tol("`4No valid bet amount was collected.")
            ovlayAndShow("`4No valid bet amount")
            return true
        end

        local tax = math.floor(Amount * Tax / 100)
        local dropAmount = Amount - tax

        logToConsole(" `6" .. input)
        tol("`9Total bet : `c" .. Amount .. "``.")
        tol("`9Tax : `c" .. Tax .. "%%``.")
        tol("`9Drop to winner : `c" .. dropAmount .. "``.")
        tol("`9Successfully took bets``.")
        ovlayAndShow("`9Successfully took bets")

        return true
    end

    if lower == "/win 1" or lower == "/win 2" then
        if not isWorldReady() then
            logToConsole(" `6" .. input)
            tol("`4World is not loaded. /win cancelled.")
            ovlayAndShow("`4World is not loaded")
            return true
        end

        if not PX1 or not PY1 or not PX2 or not PY2 then
            logToConsole(" `6" .. input)
            tol("`4Please set both positions first with /pos 1 and /pos 2.")
            ovlayAndShow("`4Set both positions first")
            return true
        end

        if Amount <= 0 then
            logToConsole(" `6" .. input)
            tol("`4No bet amount available.")
            ovlayAndShow("`4No bet amount available")
            return true
        end

        local tax = math.floor(Amount * Tax / 100)
        local win = Amount - tax
        local lock = convertLocks(win)

        local winPosition = lower == "/win 1" and 1 or 2
        local targetX, targetY = getWinPosition(winPosition)

        if not targetX or not targetY then
            logToConsole(" `6" .. input)
            tol("`4Winner position isn't detected.")
            ovlayAndShow("`4Winner position isn't detected")
            return true
        end

        sendPacketRaw(false, {
            type = 0,
            x = targetX * 32,
            y = targetY * 32,
            state = 48
        })

        ensureLocks(lock)
        SleepS(0.15)
        dropLocks(lock)

        local text = lockText(lock, true)
        local overlayText = lockText(lock, false)
        logToConsole(" `6" .. input)
        tol("`9Total bet : `c" .. Amount .. "``.")
        tol("`9Tax : `c" .. Tax .. "%%``.")
        tol("`9Drop to winner : `c" .. win .. "``.")
        tol("`9Dropped `c" .. text)
        ovlayAndShow("`9Dropped `c" .. overlayText)

        return true
    end

    if lower == "/balance" then
        local lp = getLocalPlayerSafe()
        local gems = lp and (lp.gems or 0)

        logToConsole(" `6" .. input)
        tol("`9Your gems amount : `c" .. gems .. "``.")
        tol(
            "`9Your locks amount : `c" ..
            checkitm(14860) .. " `2(C) EVL`9, `c" ..
            checkitm(9782) .. " `4(C) RGL`9, `c" ..
            checkitm(7188) .. " `eBGL`9, `c" ..
            checkitm(1796) .. " `1DL`9, `c" ..
            checkitm(242) .. " `9WL`9."
        )

        ovlayAndShow(
            "`9Your locks amount : `c" ..
            checkitm(14860) .. " `2(C) EVL`9, `c" ..
            checkitm(9782) .. " `4(C) RGL`9, `c" ..
            checkitm(7188) .. " `eBGL`9, `c" ..
            checkitm(1796) .. " `1DL`9, `c" ..
            checkitm(242) .. " `9WL"
        )

        return true
    end

    if lower == "/slog" then
        logToConsole(" `6" .. input)
        logspin()
        return true
    end

    if lower == "/time" then
        local zone = os.date("%Z")
        local date = os.date("%A, %d %B %Y")
        local time = os.date("%X")

        logToConsole(" `6" .. input)
        tol("`9Your region date : `c" .. date .. "`9.")
        tol("`9Your region time : `c" .. time .. " (" .. zone .. ")`9.")
        ovlayAndShow("`9Your region time : `c" .. time .. " (" .. zone .. ")")

        return true
    end

    if lower == "/ce" then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|el_lock_1\n\n"
        )

        logToConsole(" `6" .. input)
        ovlay("`9Compressed `c100 `4(C) Red Gem Lock")
        return true
    end

    if lower == "/be" then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|el_lock_2\n\n"
        )

        logToConsole(" `6" .. input)
        ovlay("`9Shattered `c1 `2(C) Elite Volt Lock")
        return true
    end

    if lower == "/cr" then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|ml_lock_1\n\n"
        )

        logToConsole(" `6" .. input)
        ovlay("`9Compressed `c100 `eBlue Gem Lock")
        return true
    end

    if lower == "/br" then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|ml_lock_2\n\n"
        )

        logToConsole(" `6" .. input)
        ovlay("`9Shattered `c1 `4(C) Red Gem Lock")
        return true
    end

    if lower == "/cb" then
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|chc2_2_1\n\n"
        )

        logToConsole(" `6" .. input)
        ovlay("`9Compressed `c100 `1Diamond Lock")
        return true
    end

    if lower == "/dq" then
        logToConsole(" `6" .. input)
        sendPacket(
            2,
            "action|dialog_return\ndialog_name|3898\n" ..
            "buttonClicked|turnin\n"
        )

        return true
    end

    local buyAmount = tonumber(lower:match("^/buybgl%s+(%d+)$"))

if buyAmount then
    if buyAmount > 50 then
        buyAmount = 50
    end

    local lp = getLocal()
    local pricePerBGL = 10000000
    local totalPrice = buyAmount * pricePerBGL

    if not lp or lp.gems < totalPrice then
        tol("`4You don't have enough gems.")
        ovlay("`4You don't have enough gems")
        return true
    end

    sendPacket(
        2,
        "action|dialog_return\ndialog_name|store\n" ..
        "store_btn|7188|\namount_buy|" ..
        buyAmount ..
        "\n"
    )

    logToConsole(" `6" .. input)
    tol("`9Bought `c" .. buyAmount .. " `eBlue Gem Lock`9.")
    ovlay("`9Bought `c" .. buyAmount .. " `eBlue Gem Lock")

    return true
end

    return false
end)

local uid_1 = 37
local uid_2 = 50
local accountChecked = false

local function account_check(var)
    if accountChecked then
        return false
    end

    if var[0] == "OnDialogRequest" and var[1] and var[1]:find("account id is", 1, true) then
        local uid = tonumber(var[1]:match("account id is `w#(%d+)") or var[1]:match("account id is #(%d+)"))

        if uid then
            accountChecked = true

            if uid == uid_1 or uid == uid_2 then
                ovlay("`2Account verified. Have problem? DM Discord `2@kevin.sinaga")
            else
                sendVariant({
                    [0] = "OnAddNotification",
                    [1] = "interface/particle/star.rttex",
                    [2] = "`4POOR ASF, CAN'T EVEN AFFORD THE SCRIPT",
                    [3] = "audio/slot_lose.wav"
                })

                RemoveHook("V7_Main")
                RemoveHook("V7_Command")
                logToConsole("`0Wanna buy this script? DM Discord `2@kevin.sinaga")
            end

            return true
        end
    end

    return false
end

AddHook("OnVarlist", "account_check", account_check)

sendVariant({
    [0] = "OnDialogRequest",
    [1] = loginp
}, -1, 3500)

local welcomePlayer = getLocalPlayerSafe()
local welcomeName = welcomePlayer and (welcomePlayer.name or welcomePlayer.Name) or "Player"
ovlay("`0Welcome, " .. welcomeName)
sendPacket(2, "action|input\n|text|`0Proxy by `cV7-Factory")
SleepS(5)
ovlay("`4DO NOT RESELL THIS SCRIPT!")

sleep(100)

local localPlayerForCheck = getLocal()
local localNetIDForCheck = localPlayerForCheck and (localPlayerForCheck.netId or localPlayerForCheck.netID)

if localNetIDForCheck then
    sendPacket(2, "action|wrench\n|netid|" .. localNetIDForCheck)
end
