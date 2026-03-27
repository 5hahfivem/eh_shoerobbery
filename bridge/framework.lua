local Config = require("shared.config")

QBCore, ESX = nil, nil

local function printBanner(statusLine, errorLine)
    local side = IsDuplicityVersion() and "server" or "client"
    local line = "^5============================================================^7"
    print(line)
    print("^5[eh_shoerobbery]^7 [" .. side .. "]")
    print("^2Framework loaded:^7 " .. statusLine)
    print("^1Errors/misconfig:^7 " .. (errorLine or "none"))
    print("^3Support my mission to stop the selling of shit scripts, star the repo please!^7")
    print("^6 /\\_/\\^7")
    print("^6( o.o )^7")
    print("^6 > ^ <^7")
    print(line)
end

if Config.Framework == "Qbox" then
    if GetResourceState("qbx_core") == "started" then
        printBanner("Qbox", nil)
    else
        printBanner("Qbox (not active)", "Config.Framework is Qbox but qbx_core is not started")
    end
elseif Config.Framework == "QB" then
    if GetResourceState("qb-core") == "started" then
        QBCore = exports["qb-core"]:GetCoreObject()
        printBanner("QB", nil)
    else
        printBanner("QB (not active)", "Config.Framework is QB but qb-core is not started")
    end
elseif Config.Framework == "ESX" then
    if GetResourceState("es_extended") == "started" then
        ESX = exports["es_extended"]:getSharedObject()
        printBanner("ESX", nil)
    else
        printBanner("ESX (not active)", "Config.Framework is ESX but es_extended is not started")
    end
elseif Config.Framework == "Mythic" then
    if GetResourceState("mythic-base") == "started" then
        -- Mythic components are fetched in bridge/client/mythic.lua.
        printBanner("Mythic", nil)
    else
        printBanner("Mythic (not active)", "Config.Framework is Mythic but mythic-base is not started")
    end
elseif Config.Framework == "Custom" then
    printBanner("Custom", "Custom framework selected: implement your own bridge handlers")
else
    printBanner(tostring(Config.Framework), "Invalid Config.Framework value")
end
