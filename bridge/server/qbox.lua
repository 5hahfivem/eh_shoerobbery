local Config = require("shared.config")

if Config.Framework ~= "Qbox" then return end

function AddMoney(source, amount, account, reason)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    if account == "money" then account = "cash" end
    player.Functions.AddMoney(account or "cash", math.floor(amount), reason or "shoe_robbery")
    return true
end

function GiveItem(source, item, amount, metadata)
    amount = amount or 1
    if GetResourceState("ox_inventory") ~= "started" then return false end
    local success = exports.ox_inventory:AddItem(source, item, amount, metadata or {})
    return success and true or false
end

function GetPoliceCount()
    local count = exports.qbx_core:GetDutyCountType("leo")
    return count or 0
end
